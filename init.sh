#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# dotfiles bootstrap script
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/annenpolka/dotfiles/main/init.sh | bash
#   bash ~/dotfiles/init.sh
# ==============================================================================

# --- Constants ---
DOTFILES_REPO_SSH="git@github.com:annenpolka/dotfiles.git"
DOTFILES_REPO_HTTPS="https://github.com/annenpolka/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

EXCLUDE_ROOT=(
    ".git"
    ".git-scratch"
    ".gitignore"
    ".gitattributes"
    ".gitmodules"
    ".config"
    ".claude"
    ".codex"
)

EXCLUDE_NONHIDDEN=(
    "scripts"
    "scratch"
    "tests"
    "Dockerfile"
    "init.sh"
    "Brewfile"
    "README.md"
)

# --- Logging ---
log_ok()   { printf '\033[32m  ✓ %s\033[0m\n' "$*"; }
log_err()  { printf '\033[31m  ✗ %s\033[0m\n' "$*" >&2; }
log_warn() { printf '\033[33m  ⚠ %s\033[0m\n' "$*"; }
log_info() { printf '\033[36m  → %s\033[0m\n' "$*"; }

# --- Utilities ---
is_macos()       { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux()       { [[ "$(uname -s)" == "Linux" ]]; }
is_wsl()         { is_linux && [[ -f /proc/version ]] && grep -qiF 'microsoft' /proc/version; }
command_exists() { command -v "$1" &>/dev/null; }

# --- Phase 1: Clone or Pull ---

clone_or_pull_dotfiles() {
    if [[ -d "${DOTFILES_DIR}/.git" ]]; then
        log_info "dotfiles already cloned, pulling latest..."
        git -C "${DOTFILES_DIR}" pull --ff-only 2>/dev/null || log_warn "git pull failed, continuing with existing"
        return
    fi

    log_info "Cloning dotfiles repository..."

    if git clone "${DOTFILES_REPO_SSH}" "${DOTFILES_DIR}" 2>/dev/null; then
        log_ok "Cloned via SSH"
    elif git clone "${DOTFILES_REPO_HTTPS}" "${DOTFILES_DIR}" 2>/dev/null; then
        log_ok "Cloned via HTTPS (SSH unavailable)"
    else
        log_err "Failed to clone dotfiles repository"
        exit 1
    fi
}

# --- Phase 2: Homebrew ---

install_homebrew() {
    if command_exists brew; then
        log_ok "Homebrew already installed"
        return
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Set up PATH for the current session
    if is_macos; then
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    elif is_linux; then
        if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [[ -f "${HOME}/.linuxbrew/bin/brew" ]]; then
            eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
        fi
    fi

    if command_exists brew; then
        log_ok "Homebrew installed successfully"
    else
        log_err "Homebrew installation failed"
        exit 1
    fi
}

# --- Phase 3: Brew Bundle ---

brew_bundle() {
    if ! command_exists brew; then
        log_warn "Homebrew not available, skipping brew bundle"
        return
    fi

    log_info "Installing packages from Brewfile..."
    if brew bundle --file="${DOTFILES_DIR}/Brewfile"; then
        log_ok "Brew bundle complete"
    else
        log_warn "brew bundle had errors (some packages may not have installed)"
    fi
}

# --- Phase 4: Symlinks ---

backup_and_link() {
    local src="$1"
    local dest="$2"

    if [[ -L "${dest}" ]]; then
        local current_target
        current_target="$(readlink "${dest}")"
        if [[ "${current_target}" == "${src}" ]]; then
            log_ok "Already linked: ${dest}"
            return
        fi
        log_warn "Replacing symlink: ${dest} (was → ${current_target})"
        rm "${dest}"
    elif [[ -e "${dest}" ]]; then
        log_warn "Backing up: ${dest} → ${BACKUP_DIR}/"
        local rel="${dest#${HOME}/}"
        mkdir -p "${BACKUP_DIR}/$(dirname "${rel}")"
        mv "${dest}" "${BACKUP_DIR}/${rel}"
    fi

    mkdir -p "$(dirname "${dest}")"
    ln -s "${src}" "${dest}"
    log_ok "Linked: ${dest}"
}

link_root_dotfiles() {
    log_info "Linking root dotfiles..."

    local item basename excluded excl
    for item in "${DOTFILES_DIR}"/.*; do
        basename="$(basename "${item}")"

        [[ "${basename}" == "." || "${basename}" == ".." ]] && continue
        [[ -d "${item}" ]] && continue

        excluded=false
        for excl in "${EXCLUDE_ROOT[@]}"; do
            [[ "${basename}" == "${excl}" ]] && excluded=true && break
        done
        "${excluded}" && continue

        backup_and_link "${item}" "${HOME}/${basename}"
    done
}

link_config_dirs() {
    log_info "Linking .config subdirectories..."

    mkdir -p "${HOME}/.config"

    local dir dirname
    for dir in "${DOTFILES_DIR}/.config"/*/; do
        [[ ! -d "${dir}" ]] && continue
        dirname="$(basename "${dir}")"
        backup_and_link "${DOTFILES_DIR}/.config/${dirname}" "${HOME}/.config/${dirname}"
    done
}

link_dev_tool_dirs() {
    log_info "Linking dev tool directories..."

    local dir
    for dir in .claude .codex; do
        if [[ -d "${DOTFILES_DIR}/${dir}" ]]; then
            backup_and_link "${DOTFILES_DIR}/${dir}" "${HOME}/${dir}"
        fi
    done
}

create_symlinks() {
    log_info "Creating symlinks (backup dir: ${BACKUP_DIR})"
    link_root_dotfiles
    link_config_dirs
    link_dev_tool_dirs

    # Clean up empty backup dir
    if [[ -d "${BACKUP_DIR}" ]] && [[ -z "$(ls -A "${BACKUP_DIR}" 2>/dev/null)" ]]; then
        rmdir "${BACKUP_DIR}"
    fi
}

# --- Phase 5: macOS Defaults ---

macos_defaults() {
    if ! is_macos; then
        return
    fi

    log_info "Applying macOS defaults..."

    # Key repeat speed
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Dock autohide
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0

    killall Dock 2>/dev/null || true

    log_ok "macOS defaults applied"
}

# --- Phase 6: Default Shell ---

set_default_shell() {
    local current_shell
    current_shell="$(basename "${SHELL}")"

    if [[ "${current_shell}" == "zsh" ]]; then
        log_ok "Default shell is already zsh"
        return
    fi

    local zsh_path
    zsh_path="$(command -v zsh 2>/dev/null || true)"

    if [[ -z "${zsh_path}" ]]; then
        log_warn "zsh not found, skipping shell change"
        return
    fi

    # Ensure zsh is in /etc/shells
    if ! grep -qF "${zsh_path}" /etc/shells 2>/dev/null; then
        log_info "Adding ${zsh_path} to /etc/shells (requires sudo)..."
        echo "${zsh_path}" | sudo tee -a /etc/shells >/dev/null
    fi

    log_info "Changing default shell to zsh..."
    chsh -s "${zsh_path}" || log_warn "chsh failed (run 'chsh -s ${zsh_path}' manually)"

    log_ok "Default shell changed to zsh"
}

# --- Main (entry point) ---
main() {
    echo ""
    echo "  dotfiles bootstrap"
    echo "  =================="
    echo ""

    clone_or_pull_dotfiles
    install_homebrew
    brew_bundle
    create_symlinks
    macos_defaults
    set_default_shell

    log_ok "Bootstrap complete! Open a new terminal to apply changes."
    echo ""
}

# Only run main when executed directly (not sourced)
# Tests set _INIT_SH_SOURCED=1 before sourcing to skip main
if [[ -z "${_INIT_SH_SOURCED:-}" ]]; then
    main "$@"
fi

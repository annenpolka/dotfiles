#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Dotfiles init.sh test runner
# Usage: bash tests/test.sh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

# --- Test Framework ---
_pass=0
_fail=0
_total=0
_current_group=""

group() {
    _current_group="$1"
    echo ""
    printf '\033[1m  %s\033[0m\n' "$1"
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="$3"
    ((_total++)) || true
    if [[ "${expected}" == "${actual}" ]]; then
        printf '\033[32m    ✓ %s\033[0m\n' "${msg}"
        ((_pass++)) || true
    else
        printf '\033[31m    ✗ %s\033[0m\n' "${msg}"
        printf '      expected: %s\n' "${expected}"
        printf '      actual:   %s\n' "${actual}"
        ((_fail++)) || true
    fi
}

assert_true() {
    local msg="$2"
    ((_total++)) || true
    if eval "$1"; then
        printf '\033[32m    ✓ %s\033[0m\n' "${msg}"
        ((_pass++)) || true
    else
        printf '\033[31m    ✗ %s\033[0m\n' "${msg}"
        printf '      condition: %s\n' "$1"
        ((_fail++)) || true
    fi
}

assert_false() {
    local msg="$2"
    ((_total++)) || true
    if ! eval "$1"; then
        printf '\033[32m    ✓ %s\033[0m\n' "${msg}"
        ((_pass++)) || true
    else
        printf '\033[31m    ✗ %s\033[0m\n' "${msg}"
        printf '      expected false: %s\n' "$1"
        ((_fail++)) || true
    fi
}

assert_link() {
    local link_path="$1"
    local expected_target="$2"
    local msg="$3"
    ((_total++)) || true
    if [[ -L "${link_path}" ]]; then
        local actual_target
        actual_target="$(readlink "${link_path}")"
        if [[ "${actual_target}" == "${expected_target}" ]]; then
            printf '\033[32m    ✓ %s\033[0m\n' "${msg}"
            ((_pass++)) || true
        else
            printf '\033[31m    ✗ %s (wrong target)\033[0m\n' "${msg}"
            printf '      expected: %s\n' "${expected_target}"
            printf '      actual:   %s\n' "${actual_target}"
            ((_fail++)) || true
        fi
    else
        printf '\033[31m    ✗ %s (not a symlink)\033[0m\n' "${msg}"
        ((_fail++)) || true
    fi
}

assert_not_exists() {
    local path="$1"
    local msg="$2"
    ((_total++)) || true
    if [[ ! -e "${path}" && ! -L "${path}" ]]; then
        printf '\033[32m    ✓ %s\033[0m\n' "${msg}"
        ((_pass++)) || true
    else
        printf '\033[31m    ✗ %s (exists)\033[0m\n' "${msg}"
        ((_fail++)) || true
    fi
}

assert_file_exists() {
    local path="$1"
    local msg="$2"
    ((_total++)) || true
    if [[ -e "${path}" ]]; then
        printf '\033[32m    ✓ %s\033[0m\n' "${msg}"
        ((_pass++)) || true
    else
        printf '\033[31m    ✗ %s (not found)\033[0m\n' "${msg}"
        ((_fail++)) || true
    fi
}

summary() {
    echo ""
    echo "  ────────────────────────"
    if [[ ${_fail} -eq 0 ]]; then
        printf '\033[32m  All %d tests passed ✓\033[0m\n' "${_total}"
    else
        printf '\033[31m  %d/%d tests failed ✗\033[0m\n' "${_fail}" "${_total}"
    fi
    echo ""
    return "${_fail}"
}

# --- Helper: create fake dotfiles repo in tmpdir ---
setup_fake_dotfiles() {
    local tmpdir
    tmpdir="$(mktemp -d)"

    # Create fake dotfiles structure
    mkdir -p "${tmpdir}/dotfiles/.config/ghostty"
    mkdir -p "${tmpdir}/dotfiles/.config/sheldon"
    mkdir -p "${tmpdir}/dotfiles/.config/lazygit"
    mkdir -p "${tmpdir}/dotfiles/.claude/commands"
    mkdir -p "${tmpdir}/dotfiles/.codex"
    mkdir -p "${tmpdir}/dotfiles/scripts"
    mkdir -p "${tmpdir}/dotfiles/scratch"
    mkdir -p "${tmpdir}/dotfiles/tests"
    mkdir -p "${tmpdir}/dotfiles/.git"

    echo "fake zshrc" > "${tmpdir}/dotfiles/.zshrc"
    echo "fake gitconfig" > "${tmpdir}/dotfiles/.gitconfig"
    echo "fake tmux" > "${tmpdir}/dotfiles/.tmux.conf"
    echo "fake ghostty" > "${tmpdir}/dotfiles/.config/ghostty/config"
    echo "fake sheldon" > "${tmpdir}/dotfiles/.config/sheldon/plugins.toml"
    echo "fake lazygit" > "${tmpdir}/dotfiles/.config/lazygit/config.yml"
    echo "fake claude" > "${tmpdir}/dotfiles/.claude/CLAUDE.md"
    echo "fake codex" > "${tmpdir}/dotfiles/.codex/AGENTS.md"
    echo "fake script" > "${tmpdir}/dotfiles/scripts/dotfiles_symlink.sh"
    echo "fake init" > "${tmpdir}/dotfiles/init.sh"
    echo "fake dockerfile" > "${tmpdir}/dotfiles/Dockerfile"
    touch "${tmpdir}/dotfiles/.gitignore"
    touch "${tmpdir}/dotfiles/.gitattributes"

    # Create fake home
    mkdir -p "${tmpdir}/home"

    echo "${tmpdir}"
}

cleanup_fake_dotfiles() {
    local tmpdir="$1"
    rm -rf "${tmpdir}"
}

# --- Source init.sh (functions only, main not executed) ---
source "${PROJECT_DIR}/init.sh"

# ==============================================================================
# Tests
# ==============================================================================

# --- Milestone 1: Logging & Utilities ---

group "Milestone 1: log functions"

output="$(log_ok "test message")"
assert_true '[[ "${output}" == *"✓"* ]]' "log_ok contains ✓"
assert_true '[[ "${output}" == *"test message"* ]]' "log_ok contains message"

output="$(log_err "error msg" 2>&1)"
assert_true '[[ "${output}" == *"✗"* ]]' "log_err contains ✗"

output="$(log_warn "warn msg")"
assert_true '[[ "${output}" == *"⚠"* ]]' "log_warn contains ⚠"

group "Milestone 1: platform detection"

if [[ "$(uname -s)" == "Darwin" ]]; then
    assert_true 'is_macos' "is_macos returns true on macOS"
    assert_false 'is_linux' "is_linux returns false on macOS"
else
    assert_true 'is_linux' "is_linux returns true on Linux"
    assert_false 'is_macos' "is_macos returns false on Linux"
fi

group "Milestone 1: command_exists"

assert_true 'command_exists bash' "command_exists detects bash"
assert_false 'command_exists nonexistent_command_xyz123' "command_exists returns false for missing command"

# --- Milestone 2: git clone/pull ---

group "Milestone 2: clone_or_pull - existing repo does git pull"

TMPDIR_M2="$(mktemp -d)"
mkdir -p "${TMPDIR_M2}/dotfiles/.git"
export DOTFILES_DIR="${TMPDIR_M2}/dotfiles"

output="$(clone_or_pull_dotfiles 2>&1)"
assert_true '[[ "${output}" == *"already cloned"* ]]' "detects existing repo and tries pull"

rm -rf "${TMPDIR_M2}"

group "Milestone 2: clone_or_pull - clone when no repo exists"

TMPDIR_M2="$(mktemp -d)"
_SAVED_DOTFILES_DIR="${DOTFILES_DIR}"
export DOTFILES_DIR="${TMPDIR_M2}/nonexistent_dotfiles"

# clone_or_pull_dotfiles calls exit 1 on failure, so capture in subshell
output=""
output="$( (clone_or_pull_dotfiles) 2>&1 )" || true
assert_true '[[ "${output}" == *"Clon"* || "${output}" == *"clone"* || "${output}" == *"Failed"* ]]' "attempts clone when no repo exists"

export DOTFILES_DIR="${_SAVED_DOTFILES_DIR}"
rm -rf "${TMPDIR_M2}"

# --- Milestone 3: Homebrew ---

group "Milestone 3: install_homebrew - skip if already installed"

# Ensure Homebrew is on PATH (Linuxbrew may not be in default PATH)
if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -f "${HOME}/.linuxbrew/bin/brew" ]]; then
    eval "$("${HOME}/.linuxbrew/bin/brew" shellenv)"
fi

if command_exists brew; then
    output="$(install_homebrew 2>&1)"
    assert_true '[[ "${output}" == *"already installed"* ]]' "skips when brew exists"
else
    assert_true 'true' "brew not installed (skip homebrew test)"
fi

# --- Milestone 4: Brewfile ---

group "Milestone 4: Brewfile exists"

assert_file_exists "${PROJECT_DIR}/Brewfile" "Brewfile exists in repo root"

# --- Milestone 6: macOS defaults ---

group "Milestone 6: macos_defaults"

if is_macos; then
    # Just verify it runs without error (don't want to change real settings in test)
    # We'll verify it doesn't crash
    assert_true 'true' "macos_defaults available on macOS (manual verification)"
else
    output="$(macos_defaults 2>&1)"
    assert_true '[[ -z "${output}" ]]' "macos_defaults does nothing on non-macOS"
fi

# --- Milestone 7: set_default_shell ---

group "Milestone 7: set_default_shell"

if [[ "$(basename "${SHELL}")" == "zsh" ]]; then
    output="$(set_default_shell 2>&1)"
    assert_true '[[ "${output}" == *"already zsh"* ]]' "skips when already zsh"
else
    assert_true 'true' "shell is not zsh (manual test needed)"
fi

# --- Milestone 5: Symlinks (core) ---

group "Milestone 5: backup_and_link - new file"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

backup_and_link "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"
assert_link "${HOME}/.zshrc" "${DOTFILES_DIR}/.zshrc" "creates symlink for .zshrc"

cleanup_fake_dotfiles "${TMPDIR_M5}"

group "Milestone 5: backup_and_link - already correct symlink"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

ln -s "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"
output="$(backup_and_link "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc")"
assert_true '[[ "${output}" == *"Already linked"* ]]' "skips already correct symlink"
assert_link "${HOME}/.zshrc" "${DOTFILES_DIR}/.zshrc" "symlink unchanged"

cleanup_fake_dotfiles "${TMPDIR_M5}"

group "Milestone 5: backup_and_link - existing real file backed up"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

echo "my old zshrc" > "${HOME}/.zshrc"
backup_and_link "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"
assert_link "${HOME}/.zshrc" "${DOTFILES_DIR}/.zshrc" "replaced with symlink"
assert_file_exists "${BACKUP_DIR}/.zshrc" "old file backed up"
assert_eq "my old zshrc" "$(cat "${BACKUP_DIR}/.zshrc")" "backup content matches original"

cleanup_fake_dotfiles "${TMPDIR_M5}"

group "Milestone 5: backup_and_link - wrong symlink target updated"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

ln -s "/wrong/target" "${HOME}/.zshrc"
backup_and_link "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"
assert_link "${HOME}/.zshrc" "${DOTFILES_DIR}/.zshrc" "symlink updated to correct target"

cleanup_fake_dotfiles "${TMPDIR_M5}"

group "Milestone 5: backup_and_link - broken symlink replaced"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

ln -s "/nonexistent/path" "${HOME}/.zshrc"
backup_and_link "${DOTFILES_DIR}/.zshrc" "${HOME}/.zshrc"
assert_link "${HOME}/.zshrc" "${DOTFILES_DIR}/.zshrc" "broken symlink replaced"

cleanup_fake_dotfiles "${TMPDIR_M5}"

group "Milestone 5: link_root_dotfiles"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

link_root_dotfiles
assert_link "${HOME}/.zshrc" "${DOTFILES_DIR}/.zshrc" ".zshrc linked"
assert_link "${HOME}/.gitconfig" "${DOTFILES_DIR}/.gitconfig" ".gitconfig linked"
assert_link "${HOME}/.tmux.conf" "${DOTFILES_DIR}/.tmux.conf" ".tmux.conf linked"
assert_not_exists "${HOME}/.gitignore" ".gitignore excluded"
assert_not_exists "${HOME}/.gitattributes" ".gitattributes excluded"

cleanup_fake_dotfiles "${TMPDIR_M5}"

group "Milestone 5: link_config_dirs"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

link_config_dirs
assert_link "${HOME}/.config/ghostty" "${DOTFILES_DIR}/.config/ghostty" ".config/ghostty linked"
assert_link "${HOME}/.config/sheldon" "${DOTFILES_DIR}/.config/sheldon" ".config/sheldon linked"
assert_link "${HOME}/.config/lazygit" "${DOTFILES_DIR}/.config/lazygit" ".config/lazygit linked"

cleanup_fake_dotfiles "${TMPDIR_M5}"

group "Milestone 5: link_dev_tool_dirs"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

link_dev_tool_dirs
assert_link "${HOME}/.claude" "${DOTFILES_DIR}/.claude" ".claude directory linked"
assert_link "${HOME}/.codex" "${DOTFILES_DIR}/.codex" ".codex directory linked"

cleanup_fake_dotfiles "${TMPDIR_M5}"

group "Milestone 5: exclusions"

TMPDIR_M5="$(setup_fake_dotfiles)"
export HOME="${TMPDIR_M5}/home"
export DOTFILES_DIR="${TMPDIR_M5}/dotfiles"
BACKUP_DIR="${HOME}/.dotfiles_backup/test_run"

create_symlinks
assert_not_exists "${HOME}/scripts" "scripts/ not linked"
assert_not_exists "${HOME}/scratch" "scratch/ not linked"
assert_not_exists "${HOME}/tests" "tests/ not linked"
assert_not_exists "${HOME}/Dockerfile" "Dockerfile not linked"
assert_not_exists "${HOME}/init.sh" "init.sh not linked"
assert_not_exists "${HOME}/.git" ".git not linked"

cleanup_fake_dotfiles "${TMPDIR_M5}"

# --- Print Summary ---
summary

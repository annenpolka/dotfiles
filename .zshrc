# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/annenpolka/.zsh/completions:"* ]]; then export FPATH="/Users/annenpolka/.zsh/completions:$FPATH"; fi
#  ╭──────────────────────────────────────────────────────────╮
#  │                          envvars                         │
#  ╰──────────────────────────────────────────────────────────╯
## keybind
bindkey -e
## auto cd
setopt AUTO_CD
## history
export HISTFILE=$HOME/.zsh_history
export HISTFILESIZE=1000000
export HISTSIZE=100000
export SAVEHIST=100000000
setopt hist_ignore_dups
setopt inc_append_history share_history

# auto cd
setopt AUTO_CD

# default editor
export EDITOR=nvim

# cargo(Rust)
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/:$PATH"

# ghcup(Haskell)
export PATH="$HOME/.ghcup/bin:$PATH"

# GOPATH
export PATH="$PATH:$(go env GOPATH)/bin"

# local bin
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

## pipenvの仮想環境をプロジェクトローカルに作る
export PIPENV_VENV_IN_PROJECT=true

if [[ -f "$HOME/.secrets" ]]; then
  source "$HOME/.secrets"
fi

# homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
#  ╭──────────────────────────────────────────────────────────╮
#  │                        aliases                           │
#  ╰──────────────────────────────────────────────────────────╯
# copy pwd on mac
alias cpwd='pwd | pbcopy && echo "現在のパスをコピーしました"'
## lazygit = lg
alias lg=lazygit
## lazydocker = lz
alias lz=lazydocker

# podman-remote
# alias podman='podman-remote-static-linux_amd64'

## xplr with cd on exit
alias xcd='cd "$(xplr --print-pwd-as-result)"'

## Ctrl+Eでvifmを呼び出すついでに抜けた時ディレクトリ移動するようにする
function vicd() {
  local dst="$(command vifm $1 $2 --choose-dir -)"
  if [ -z "$dst" ]; then
    echo 'Directory picking cancelled/failed'
    return 1
  fi
  cd "$dst"
}
bindkey -s '^E' 'y . \n'

## yazi with cd on exit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

## ezaで幸せなlsライフを送る
if [[ $(command -v eza) ]]; then
  alias e='eza --icons'
  alias l=e
  alias ls=e
  alias ea='eza -a --icons'
  alias la=ea
  alias ee='eza -aal --icons'
  alias ll=ee
  alias et='eza -T -L 3 -a -I "node_modules|.git|.cache" --icons'
  alias lt=et
  alias eta='eza -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
  alias lta=eta
fi

# Python3 関連のエイリアス（OS別）
if [[ "$(uname -s)" == "Darwin" ]]; then
  # macOS環境の場合の設定
  alias python='python3'
  alias pip='pip3'
fi

## neovim startup time check
# alias nvtime="nvim --startuptime ./startup.log"

## emacs daemon aliases
# alias ec="emacsclient -n -c"
# alias er="emacsclient -e '(kill-emacs)' ; emacs --daemon"

# create temporary neovim environment
function nvim-minimal-env() {
  cd "$(mktemp -d)"
  local -x HOME=$PWD
  local -x XDG_CONFIG_HOME=$HOME/.config
  local -x XDG_DATA_HOME=$HOME/.local/share
  local -x XDG_CACHE_HOME=$HOME/.cache
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  mkdir -p ~/.config/nvim
  cat <<EOF >~/.config/nvim/init.vim
syntax enable
filetype plugin indent on

call plug#begin(stdpath('data') . '/plugged')
" Plug ''
call plug#end()
EOF
  mkdir -p ~/.config/vifm
  ln -s /home/annenpolka/.config/vifm/vifmrc ~/.config/vifm
  pwd
  ls -la
}

#
# ghq-fzf.zsh
#
# ABOUT:
#   `cd` to `ghq` repositories directory on `zsh`
#   You can launch this function with `Ctrl-g`
#
# INSTALLATION:
#   Requires `zsh` and `fzf`
#   Download this file then, append `source path/to/fzf-ghq.zsh` to your `~/.zshrc`
#   or copy & paste to your `~/.zshrc`
# 

function _fzf_cd_ghq() {
    FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --reverse --height=50%"
    local root="$(ghq root)"
    local repo="$(ghq list | fzf --preview="ls -AF --color=always ${root}/{1}")"
    local dir="${root}/${repo}"
    [ -n "${dir}" ] && cd "${dir}"
    zle accept-line
    zle reset-prompt
}

zle -N _fzf_cd_ghq
bindkey "^g" _fzf_cd_ghq

# ;; -----------------------------------------------------------
#
# ;; -----------------------------------------------------------
# (provide 'init)
# EOF
#   # vifm setup
#   mkdir -p ~/.config/vifm
#   ln -s /home/annenpolka/.config/vifm/vifmrc ~/.config/vifm
#
#   pwd
#   ls -la
# }

# --- alias scripts

# direnv
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT="" # 静かにしてもらう

# zoxide
eval "$(zoxide init zsh)"

#  ╭──────────────────────────────────────────────────────────╮
#  │                      Initialization                      │
#  ╰──────────────────────────────────────────────────────────╯

#sheldon the plugin manager
eval "$(sheldon source)"

##THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/annenpolka/.sdkman"
[[ -s "/home/annenpolka/.sdkman/bin/sdkman-init.sh" ]] && source "/home/annenpolka/.sdkman/bin/sdkman-init.sh"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

. "/Users/annenpolka/.deno/env"
# Initialize zsh completions (added by deno install script)
autoload -Uz compinit
compinit

# Load git-gtr completions (REQUIRED - must be sourced after compinit)
source ~/.zsh/completions/_git-gtr

# Load Angular CLI autocompletion.
# source <(ng completion script)
eval "$(mise activate zsh)"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Added by Antigravity
export PATH="/Users/annenpolka/.antigravity/antigravity/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/annenpolka/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# bun completions
[ -s "/Users/annenpolka/.bun/_bun" ] && source "/Users/annenpolka/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# moonbit
export PATH="$HOME/.moon/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/annenpolka/.cache/lm-studio/bin"
# End of LM Studio CLI section


# opencode
export PATH=/Users/annenpolka/.opencode/bin:$PATH

# git-wt completion
eval "$(git wt --init zsh)"

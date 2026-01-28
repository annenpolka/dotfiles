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
export EDITOR=hx

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
export PATH="/opt/homebrew/bin:$PATH"
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
bindkey -s '^E' 'vicd . \n'

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

alias ssh-whoo-dev='_ssh-whoo-dev'
function _ssh-whoo-dev() {
  local -x ROLE_NAME="REDACTED_ARN"
  local -x SESSION_NAME="whoo-dev"
  aws sts assume-role --role-arn ${ROLE_NAME} --role-session-name ${SESSION_NAME} > /tmp/${SESSION_NAME}.sts
  local -x AWS_SECRET_ACCESS_KEY=$(cat /tmp/${SESSION_NAME}.sts | grep SecretAccessKey | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  local -x AWS_ACCESS_KEY_ID=$(cat /tmp/${SESSION_NAME}.sts | grep AccessKeyId | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  local -x AWS_SESSION_TOKEN=$(cat /tmp/${SESSION_NAME}.sts | grep SessionToken | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  rm /tmp/${SESSION_NAME}.sts
  ssh whoodev-gateway
}
alias scp-whoo-dev='_scp-whoo-dev'
function _scp-whoo-dev() {
  local -x ROLE_NAME="REDACTED_ARN"
  local -x SESSION_NAME="whoo-dev"
  # JSONパース無しで3値を受け取る
  read -r AK SK ST < <(aws sts assume-role \
    --role-arn "${ROLE_NAME}" \
    --role-session-name "${SESSION_NAME}" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text)
  local -x AWS_ACCESS_KEY_ID="$AK" AWS_SECRET_ACCESS_KEY="$SK" AWS_SESSION_TOKEN="$ST"
  scp "$@"        # ← 以降の引数をそのままscpへ
}
alias ssh-whoo-prod='_ssh-whoo-prod'
function _ssh-whoo-prod() {
  local -x ROLE_NAME="REDACTED_ARN"
  local -x SESSION_NAME="whoo-prod"
  aws sts assume-role --role-arn ${ROLE_NAME} --role-session-name ${SESSION_NAME} > /tmp/${SESSION_NAME}.sts
  local -x AWS_SECRET_ACCESS_KEY=$(cat /tmp/${SESSION_NAME}.sts | grep SecretAccessKey | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  local -x AWS_ACCESS_KEY_ID=$(cat /tmp/${SESSION_NAME}.sts | grep AccessKeyId | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  local -x AWS_SESSION_TOKEN=$(cat /tmp/${SESSION_NAME}.sts | grep SessionToken | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  rm /tmp/${SESSION_NAME}.sts
  ssh whooprod-gateway
}
alias scp-whoo-prod='_scp-whoo-prod'
function _scp-whoo-prod() {
  local -x ROLE_NAME="REDACTED_ARN"
  local -x SESSION_NAME="whoo-prod"
  # JSONパース無しで3値を受け取る
  read -r AK SK ST < <(aws sts assume-role \
    --role-arn "${ROLE_NAME}" \
    --role-session-name "${SESSION_NAME}" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text)
  local -x AWS_ACCESS_KEY_ID="$AK" AWS_SECRET_ACCESS_KEY="$SK" AWS_SESSION_TOKEN="$ST"
  scp "$@"        # ← 以降の引数をそのままscpへ
}


alias ssh-flipout-dev='_ssh-flipout-dev'
function _ssh-flipout-dev() {
  local -x ROLE_NAME="REDACTED_ARN"
  local -x SESSION_NAME="flipout-dev"
  aws sts assume-role --role-arn ${ROLE_NAME} --role-session-name ${SESSION_NAME} > /tmp/${SESSION_NAME}.sts
  local -x AWS_SECRET_ACCESS_KEY=$(cat /tmp/${SESSION_NAME}.sts | grep SecretAccessKey | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  local -x AWS_ACCESS_KEY_ID=$(cat /tmp/${SESSION_NAME}.sts | grep AccessKeyId | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  local -x AWS_SESSION_TOKEN=$(cat /tmp/${SESSION_NAME}.sts | grep SessionToken | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  rm /tmp/${SESSION_NAME}.sts
  ssh flipoutdev-gateway
}

alias ssh-flipout-prod='_ssh-flipout-prod'
function _ssh-flipout-prod() {
  local -x ROLE_NAME="REDACTED_ARN"
  local -x SESSION_NAME="flipout-prod"
  aws sts assume-role --role-arn ${ROLE_NAME} --role-session-name ${SESSION_NAME} > /tmp/${SESSION_NAME}.sts
  local -x AWS_SECRET_ACCESS_KEY=$(cat /tmp/${SESSION_NAME}.sts | grep SecretAccessKey | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  local -x AWS_ACCESS_KEY_ID=$(cat /tmp/${SESSION_NAME}.sts | grep AccessKeyId | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  local -x AWS_SESSION_TOKEN=$(cat /tmp/${SESSION_NAME}.sts | grep SessionToken | awk {'print $2'} | sed -e 's/"//g' | sed -e 's/,//')
  rm /tmp/${SESSION_NAME}.sts
  ssh flipoutprod-gateway
}


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

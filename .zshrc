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

# local bin
export PATH="$HOME/.local/bin:$PATH"


# emacs vterm configuration
# if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
#     alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
# fi
# if [[ "$INSIDE_EMACS" = 'vterm' ]] \
#     && [[ -n ${EMACS_VTERM_PATH} ]] \
#     && [[ -f ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh ]]; then
# 	source ${EMACS_VTERM_PATH}/etc/emacs-vterm-zsh.sh
# fi

#  ╭──────────────────────────────────────────────────────────╮
#  │                        aliases                           │
#  ╰──────────────────────────────────────────────────────────╯

## lazygit = lg
alias lg=lazygit
## lazydocker = lz
alias lz=lazydocker

alias gx="gh copilot explain"
alias gs="gh copilot suggest"

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

## neovim startup time check
# alias nvtime="nvim --startuptime ./startup.log"

## emacs daemon aliases
# alias ec="emacsclient -n -c"
# alias er="emacsclient -e '(kill-emacs)' ; emacs --daemon"

# create temporary neovim environment
function nvim-minimal-env() {
  cd "$(mktemp -d)"
  export HOME=$PWD
  export XDG_CONFIG_HOME=$HOME/.config
  export XDG_DATA_HOME=$HOME/.local/share
  export XDG_CACHE_HOME=$HOME/.cache
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  mkdir -p ~/.config/nvim
  cat << EOF > ~/.config/nvim/init.vim
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

# create temporary emacs environment
# function emacs-minimal-env() {
#   cd "$(mktemp -d)"
#   export HOME=$PWD
#   export XDG_CONFIG_HOME=$HOME/.config
#   export XDG_DATA_HOME=$HOME/.local/share
#   export XDG_CACHE_HOME=$HOME/.cache
#   mkdir -p ~/.emacs.d/
#   cat << EOF > ~/.emacs.d/init.el
#   ;;; init.el --- My init.el  -*- lexical-binding: t; -*-
#
# ;; this enables this running method
# ;;   emacs -q -l ~/.debug.emacs.d/{{pkg}}/init.el
# (eval-and-compile
#   (when (or load-file-name byte-compile-current-file)
#     (setq user-emacs-directory
#           (expand-file-name
#            (file-name-directory (or load-file-name byte-compile-current-file))))))
#
# (eval-and-compile
#   (customize-set-variable
#    'package-archives '(("org"   . "https://orgmode.org/elpa/")
#                        ("melpa" . "https://melpa.org/packages/")
#                        ("gnu"   . "https://elpa.gnu.org/packages/")))
#   (package-initialize)
#   (unless (package-installed-p 'leaf)
#     (package-refresh-contents)
#     (package-install 'leaf))
#
#   (leaf leaf-keywords
#     :ensure t
#     :config
#     ;; initialize leaf-keywords.el
#     (leaf-keywords-init)))
#
# (setq inhibit-splash-screen t)
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

# initialize thefuck
eval $(thefuck --alias)

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

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

# include ac-library
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:~/.local/lib/ac-library"

# cargo(Rust)
export PATH="$HOME/.cargo/bin:$PATH"

# ghcup(Haskell)
export PATH="$HOME/.ghcup/bin:$PATH"

# local bin
export PATH="$HOME/.local/bin:$PATH"

#  ╭──────────────────────────────────────────────────────────╮
#  │                        aliases                           │
#  ╰──────────────────────────────────────────────────────────╯

## lazygit = lg
alias lg=lazygit
## lazydocker = lz
alias lz=lazydocker

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

## exaで幸せなlsライフを送る
if [[ $(command -v exa) ]]; then
  alias e='exa --icons'
  alias l=e
  alias ls=e
  alias ea='exa -a --icons'
  alias la=ea
  alias ee='exa -aal --icons'
  alias ll=ee
  alias et='exa -T -L 3 -a -I "node_modules|.git|.cache" --icons'
  alias lt=et
  alias eta='exa -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
  alias lta=eta
fi

  
## neovim startup time check
alias nvtime="nvim --startuptime ./startup.log"

## initialize thefuck
eval $(thefuck --alias)

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

function nvim-minimal-env-packer() {
  cd "$(mktemp -d)"
  export HOME=$PWD
  export XDG_CONFIG_HOME=$HOME/.config
  export XDG_DATA_HOME=$HOME/.local/share
  export XDG_CACHE_HOME=$HOME/.cache
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  mkdir -p ~/.config/nvim
  cat << EOF > ~/.config/nvim/init.lua
vim.cmd [[syntax enable]]
vim.cmd [[filetype plugin indent on]]

local execute = vim.api.nvim_command
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  use {'wbthomason/packer.nvim', opt = true}
end)
EOF
# do not write under this line because it was returned

  mkdir -p ~/.config/vifm
  ln -s /home/annenpolka/.config/vifm/vifmrc ~/.config/vifm
  pwd
  ls -la
}

alias nvim-packersync="nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"

# create temporary emacs environment
function emacs-minimal-env() {
  cd "$(mktemp -d)"
  export HOME=$PWD
  export XDG_CONFIG_HOME=$HOME/.config
  export XDG_DATA_HOME=$HOME/.local/share
  export XDG_CACHE_HOME=$HOME/.cache
  mkdir -p ~/.emacs.d/
  cat << EOF > ~/.emacs.d/init.el
  ;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/{{pkg}}/init.el
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org"   . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

(setq inhibit-splash-screen t)
;; -----------------------------------------------------------

;; -----------------------------------------------------------
(provide 'init)
EOF
  # vifm setup
  mkdir -p ~/.config/vifm
  ln -s /home/annenpolka/.config/vifm/vifmrc ~/.config/vifm

  pwd
  ls -la
}

# --- unsettled

# direnv
eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT="" # 静かにしてもらう


#  ╭──────────────────────────────────────────────────────────╮
#  │                      Initialization                      │
#  ╰──────────────────────────────────────────────────────────╯

##THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/annenpolka/.sdkman"
[[ -s "/home/annenpolka/.sdkman/bin/sdkman-init.sh" ]] && source "/home/annenpolka/.sdkman/bin/sdkman-init.sh"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
source ~/.zinitrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

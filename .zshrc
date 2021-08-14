# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Executes commands at the start of an interactive session.
#

# --- envvars
## history 
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
## ページャーをbatにする
export PAGER='bat'


# --- aliases
## Ctrl+Eでvifmを呼び出すついでに抜けた時ディレクトリ移動するようにする
function vicd() {
    local dst="$(command vifm $1 $2 --choose-dir -)"
    if [ -z "$dst" ]; then
        echo 'Directory picking cancelled/failed'
        return 1
    fi
    cd "$dst"
}
bindkey -s '^E' '^a vicd . \n'

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

  
# --- unsettled

# Windows側のGoパッケージのパス
# gocopy, gopasteによるクリップボードアクセスに使う
export PATH="$PATH:/mnt/c/Users/lance/go/bin"

# Windows側のあれそれを都合よく叩く用パス
export PATH="$PATH:/mnt/c/users/lance/.path/"

# ~/binにWin32yankを置いたので
export PATH="$PATH:$HOME/bin/"

# cargo系パス
export PATH="$PATH:$HOME/.cargo/bin"

# codeコマンドのパス通す
export PATH="$PATH:/mnt/e/Microsoft VS Code/bin"

# pipenvの仮想環境をプロジェクトローカルに作る
export PIPENV_VENV_IN_PROJECT=true

# Windows側のzenhan叩く
export zenhan='/mnt/c/Users/lance/scoop/shims/zenhan.exe'

# alias for pip3
alias pip=pip3

# x server
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0

# Windows側でopen
function open() { /mnt/c/Windows/System32/cmd.exe /c start $(wslpath -w $1) }

# Go
export PATH=$PATH:/usr/local/go/bin

# パッケージの探索範囲絡みのパスらしい
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/annenpolka/.sdkman"
[[ -s "/home/annenpolka/.sdkman/bin/sdkman-init.sh" ]] && source "/home/annenpolka/.sdkman/bin/sdkman-init.sh"

# direnv
eval "$(direnv hook zsh)"

# zplug
export ZPLUG_HOME=/home/linuxbrew/.linuxbrew/opt/zplug
source ./.zplugrc

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

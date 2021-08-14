# --- options
# Indentation
set-option global tabstop 4
set-option global indentwidth 4

# cursor
hook global ModeChange insert:.* %{
    set-face global PrimaryCursor      rgb:ffffff,rgb:000000+F
}

hook global ModeChange .*:insert %{
    set-face global PrimaryCursor      rgb:ffffff,rgb:008800+F
}

# rc files detection
hook global BufCreate .*\..*rc %{ set buffer filetype sh }

# --- plugins
# ide command
def ide %{
    rename-client main
    set global jumpclient main

    new rename-client tools
    set global toolsclient tools

    new rename-client docs
    set global docsclient docs
}

#  plug.kak
evaluate-commands %sh{
        plugins="$kak_config/plugins"
            mkdir -p "$plugins"
                [ ! -e "$plugins/plug.kak" ] && \
                        git clone -q https://github.com/andreyorst/plug.kak.git "$plugins/plug.kak"
                            printf "%s\n" "source '$plugins/plug.kak/rc/plug.kak'"


}
plug "andreyorst/plug.kak" noload config %{
    set-option global plug_always_ensure 'true'
}
# language server protocol
plug "kak-lsp/kak-lsp" do %{
    cargo install --locked --force --path .
} config %{
    lsp-enable
    lsp-auto-hover-enable
}

plug "alexherbo2/tmux.kak" config %{
	tmux-integration-enable
}

# File Manager
plug "andreyorst/kaktree" config %{
    hook global WinSetOption filetype=kaktree %{
        remove-highlighter buffer/numbers
        remove-highlighter buffer/matching
	remove-highlighter buffer/wrap
        remove-highlighter buffer/show-whitespaces
    }
    kaktree-enable
}

# share clipboard
plug "lePerdu/kakboard" %{
    hook global WinCreate .* %{ kakboard-enable }
}

# fuzzy finder
plug "andreyorst/fzf.kak" config %{
    map global normal <c-p> ': fzf-mode<ret>'
}

# smarttab indentation
plug "andreyorst/smarttab.kak" defer smarttab %{
    # when `backspace' is pressed, 4 spaces are deleted at once
    set-option global softtabstop 4
}
# powerline
plug "andreyorst/powerline.kak"  defer powerline %{
    powerline-format global 'git bufname filetype mode_info line_column position'
    } defer powerline_bufname %{
    set-option global powerline_shorten_bufname 'short'
} defer powerline_zenburn %{
    powerline-theme zenburn
} config %{
    powerline-start
}

# surround
plug "h-youhei/kakoune-surround" config %{
    declare-user-mode surround
    map global surround s ':surround<ret>' -docstring 'surround'
    map global surround c ':change-surround<ret>' -docstring 'change'
    map global surround d ':delete-surround<ret>' -docstring 'delete'
    map global surround t ':select-surrounding-tag<ret>' -docstring 'select tag'
    map global normal s ':enter-user-mode surround<ret>'
}

# buffer manager
plug 'delapouite/kakoune-buffers' %{
  map global normal q ': enter-buffers-mode<ret>' -docstring 'buffers'
  map global normal Q ': enter-user-mode -lock buffers<ret>' -docstring 'buffers (lock)'
}
  
# --- keybindings
    
# jj and jk escape
hook global InsertChar j %{ try %{
    exec -draft hH <a-k>jj<ret> d
  exec <esc>
}}

hook global InsertChar k %{ try %{
      exec -draft hH <a-k>jk<ret> d
        exec <esc>
}}

# C-i and C-a 
map global normal <tab> <A-i> # <C-i> decoded as <tab> in terminal
map global normal <C-a> <A-a>


#!/bin/bash

# Constants
DOTFILES_REPO="https://github.com/your-username/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Functions
clone_or_pull_dotfiles() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  else
    cd "$DOTFILES_DIR"
    git pull
  fi
}

create_symlink() {
  local source="$1"
  local target="$2"

  if [ -e "$target" ]; then
    if [ "$FORCE_FLAG" = true ]; then
      rm -rf "$target"
    else
      if [ ! -L "$target" ]; then
        echo "File or directory $target already exists. Cannot create symbolic link."
        return
      fi
    fi
  fi

  local target_dir
  target_dir=$(dirname "$target")
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
  fi

  ln -s "$source" "$target"
  echo "Symbolic link created: $source -> $target"
}

create_symlinks() {
  cd "$DOTFILES_DIR"
  find . -type f -or -type d | while read -r item; do
    if [ "$item" != "." ] && [ "$item" != ".git" ]; then
      local source="$DOTFILES_DIR/$item"
      local target="$HOME/${item#./}"
      create_symlink "$source" "$target"
    fi
  done
}

# Main
FORCE_FLAG=false

while getopts ":f" opt; do
  case $opt in
    f)
      FORCE_FLAG=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

clone_or_pull_dotfiles
create_symlinks
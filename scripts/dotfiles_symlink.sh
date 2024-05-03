#!/bin/bash

# Constants
DOTFILES_DIR="$HOME/dotfiles"

# Global exclude list
GLOBAL_EXCLUDE=(
	".git"
	".gitignore"
	".gitattributes"
	".gitmodules"
	"dockerfile"
)

# Functions
is_item_excluded() {
	local item="$1"
	for exclude in "${GLOBAL_EXCLUDE[@]}"; do
		if [[ "$item" == "$exclude" || "$item" == */"$exclude" ]]; then
			return 0
		fi
	done
	return 1
}

create_symlink() {
	local source="$1"
	local target="$2"

	if [ -e "$target" ]; then
		if [ "$FORCE_FLAG" = true ]; then
			rm -rf "$target"
		else
			if [ ! -L "$target" ]; then
				echo "ファイルまたはディレクトリ $target が既に存在します。シンボリックリンクを作成できません。"
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
	echo "シンボリックリンクを作成しました: $source -> $target"
}

create_symlinks_by_rule() {
	local directory="$1"
	local rule_func="$2"

	cd "$DOTFILES_DIR"
	find "$directory" -maxdepth 1 -type f -or -type d | while read -r item; do
		if [ "$item" != "$directory" ] && ! is_item_excluded "$item"; then
			local source="$DOTFILES_DIR/$item"
			local target="$HOME/${item#./}"

			if "$rule_func" "$source"; then
				create_symlink "$source" "$target"
			fi
		fi
	done
}

# Rule functions
rule_directory() {
	local source="$1"
	[ -d "$source" ]
}

rule_file() {
	local source="$1"
	[ -f "$source" ]
}

# Check option flags
FORCE_FLAG=false

while getopts ":f" opt; do
	case $opt in
	f)
		FORCE_FLAG=true
		;;
	\?)
		echo "無効なオプション: -$OPTARG" >&2
		exit 1
		;;
	esac
done

# User-defined rules
create_symlinks_by_rule ".config" "rule_directory"
create_symlinks_by_rule "." "rule_file"

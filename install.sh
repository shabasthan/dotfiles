#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

configs=(btop fastfetch hypr kitty nvim nwg-bar nwg-look rofi sway swaync waybar)

for name in "${configs[@]}"; do
    target="$CONFIG/$name"
    source="$DOTFILES/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target -> $target.bak"
        mv "$target" "$target.bak"
    fi

    ln -sfn "$source" "$target"
    echo "Linked $name"
done

echo "Done. Restart your session or reload configs."

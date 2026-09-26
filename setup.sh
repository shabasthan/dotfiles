#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting Restore Script"

# 1. Enable multilib if disabled
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "==> Enabling [multilib] in /etc/pacman.conf..."
    sudo sed -i '/#\[multilib\]/{n;s/#//}' /etc/pacman.conf
    sudo sed -i 's/#\[multilib\]/\[multilib\]/' /etc/pacman.conf
    sudo pacman -Sy
fi

# 2. Refresh pacman database
sudo pacman -Sy

# 3. Install official packages
if [ -f "$DOTFILES_DIR/pkglist.txt" ]; then
    echo "==> Installing native packages..."
    sudo pacman -S --needed --noconfirm - < "$DOTFILES_DIR/pkglist.txt"
fi

# 4. Install yay if missing
if ! command -v yay &> /dev/null; then
    echo "==> Installing yay..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# 5. Install AUR packages
if [ -f "$DOTFILES_DIR/aurlist.txt" ]; then
    echo "==> Installing AUR packages..."
    yay -S --needed --noconfirm - < "$DOTFILES_DIR/aurlist.txt"
fi

# 6. Install Flatpaks
if [ -f "$DOTFILES_DIR/flatpaklist.txt" ]; then
    echo "==> Installing Flatpaks..."
    if ! command -v flatpak &> /dev/null; then
        sudo pacman -S --needed --noconfirm flatpak
    fi
    xargs -a "$DOTFILES_DIR/flatpaklist.txt" flatpak install -y
fi

# 7. Restore configuration directories
echo "==> Restoring dotfiles and configs..."
mkdir -p ~/.config ~/.local/state ~/.local/share

[ -d "$DOTFILES_DIR/config" ] && cp -rf "$DOTFILES_DIR/config/"* ~/.config/
[ -d "$DOTFILES_DIR/local_state" ] && cp -rf "$DOTFILES_DIR/local_state/"* ~/.local/state/
[ -d "$DOTFILES_DIR/local_share" ] && cp -rf "$DOTFILES_DIR/local_share/"* ~/.local/share/
[ -d "$DOTFILES_DIR/home" ] && cp -rf "$DOTFILES_DIR/home/".* ~/ 2>/dev/null || true

echo "==> Restore complete! Restart your session or reload Hyprland."

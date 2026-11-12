#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

PACKAGES=(
    # Desktop
    hyprland hyprpaper hyprlock waybar wofi
    xdg-desktop-portal xdg-desktop-portal-hyprland qt6ct gsettings-desktop-schemas
    # Apps used by keybindings / autostart
    ghostty thunar firefox hyprshot brightnessctl pamixer psmisc
    pavucontrol bluetui
    # Audio (pamixer needs a pulse server)
    pipewire pipewire-pulse wireplumber
    # Fonts used by waybar, wofi, ghostty, hyprlock
    otf-font-awesome ttf-roboto ttf-roboto-mono ttf-jetbrains-mono-nerd
)
AUR_PACKAGES=(zen-browser-bin dualsensectl)

# sudo pacman -Syu --needed "${PACKAGES[@]}"

# if command -v yay >/dev/null; then
#     yay -S --needed "${AUR_PACKAGES[@]}"
# elif command -v paru >/dev/null; then
#     paru -S --needed "${AUR_PACKAGES[@]}"
# else
#     echo "No AUR helper found, install manually: ${AUR_PACKAGES[*]}" >&2
# fi

CONFIG="$HOME/.config"
mkdir -p "$CONFIG/hypr/wallpaper" "$CONFIG/ghostty" "$CONFIG/wofi" "$CONFIG/waybar"

cp ./hyprland/hyprland.lua "$CONFIG/hypr/"
cp ./hyprlock/hyprlock.conf "$CONFIG/hypr/"
cp ./wofi/style.css "$CONFIG/wofi/"
cp ./hyprpaper/hyprpaper.conf "$CONFIG/hypr/"
cp ./hyprpaper/wallpaper/* "$CONFIG/hypr/wallpaper/"
cp ./ghostty/config "$CONFIG/ghostty/config"

cp ./waybar/config ./waybar/style.css "$CONFIG/waybar/"

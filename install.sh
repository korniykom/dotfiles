#!/bin/bash
 #pacman -Syu hyprland ghostty firefox waybar wofi thunar  hyprpaper hyprlock brightnessctl pamixer ttf-font-awesome ttf-roboto 
cp ./hyprland/hyprland.conf /home/max/.config/hypr
cp ./hyprlock/hyprlock.conf /home/max/.config/hypr
cp -r ./wofi /home/max/.config/
cp ./hyprpaper/hyprpaper.conf /home/max/.config/hypr
cp -r ./hyprpaper/wallpaper /home/max/.config/hypr
cp ./ghostty/config /home/max/.config/ghostty

cp ./waybar/style.css  /etc/xdg/waybar/style.css
cp ./waybar/config /etc/xdg/waybar/config

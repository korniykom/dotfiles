#!/bin/bash
pacman -Syu hyprland kitty firefox waybar wofi thunar kitty hyprpaper hyprlock brightnessctl pamixer ttf-font-awesome ttf-roboto 
echo Install hyprshot via aur
cp ./hyprland/hyprland.conf /home/max/.config/hypr
cp ./hyprlock/hyprlock.conf /home/max/.config/hypr
cp -r ./kitty /home/max/.config/
cp -r ./wofi /home/max/.config/
cp ./hyprpaper/hyprpaper.conf /home/max/.config/hypr
cp ./hyprpaper/wallpaper.png /home/max/.config/hypr


cp ./waybar/style.css ./waybar/config /etc/xdg/waybar
cp ./waybar/config /etc/xdg/waybar

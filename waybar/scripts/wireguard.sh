#!/bin/bash
# WireGuard status/toggle for waybar image module (wg-quick@$IFACE, root via polkit)
# Status output: image path on line 1, tooltip on line 2
IFACE=wg0
ICONS="$HOME/.config/waybar/icons"

is_up() { [ -d "/sys/class/net/$IFACE" ]; }

case "${1:-status}" in
    toggle)
        # systemctl needs a running agent to show the password prompt
        systemctl --user is-active --quiet hyprpolkitagent || systemctl --user start hyprpolkitagent
        if is_up; then
            systemctl stop "wg-quick@$IFACE"
        else
            systemctl start "wg-quick@$IFACE"
        fi
        pkill -RTMIN+8 waybar
        ;;
    *)
        if is_up; then
            ip4=$(ip -4 -br addr show "$IFACE" | awk '{print $3}')
            printf '%s\nWireGuard: %s %s\n' "$ICONS/wireguard.png" "$IFACE" "$ip4"
        else
            printf '%s\nWireGuard: off\n' "$ICONS/wireguard-off.png"
        fi
        ;;
esac

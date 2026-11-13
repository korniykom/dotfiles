-- Hyprland native Lua configuration
-- Migrated from the previous hyprland.conf.
-- This file is loaded directly by Hyprland; no generator is needed.

------------------
-- MONITORS
------------------

-- Keep the original monitor positions and refresh rates.
hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60.04",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60.00",
    position = "1920x0",
    scale = 1,
})

hl.monitor({
    output = "HDMI-A-2",
    mode = "1920x1080@60.00",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "DVI-D-1",
    mode = "1280x1024@75.03",
    position = "1920x0",
    scale = 1,
})

hl.monitor({
    output = "DP-1",
    mode = "1280x1024@75.03",
    position = "-1280x0",
    scale = 1,
})


------------------
-- PROGRAMS
------------------

local terminal = "ghostty"
local fileManager = "thunar"
local menu = "wofi --show drun"
local browser = "zen-browser"
local mainMod = "SUPER"


------------------
-- AUTOSTART
------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal")

    hl.exec_cmd("waybar")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)


------------------
-- ENVIRONMENT
------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("ELECTRON_ENABLE_WAYLAND", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("MOZ_USE_XINPUT2", "1")


------------------
-- CURSOR
------------------

hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})


------------------
-- INPUT
------------------

hl.config({
    input = {
        kb_layout = "us,ua",
        kb_variant = "",
        kb_model = "",
        kb_options = "grp:win_space_toggle",
        kb_rules = "",

        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = 0.5,
})


------------------
-- GENERAL / APPEARANCE
------------------

hl.config({
    general = {
        gaps_workspaces = 80,
        gaps_in = 0,
        gaps_out = 0,
        border_size = 2,

        col = {
            active_border = "rgba(11111111)",
            inactive_border = "rgba(11111122)",
        },

        layout = "dwindle",
        allow_tearing = false,
    },

    decoration = {
        rounding = 1,
        active_opacity = 1.0,
        inactive_opacity = 0.97,
        fullscreen_opacity = 1.0,

        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            new_optimizations = true,
        },
    },

    misc = {
        force_default_wallpaper = 0,
    },

    dwindle = {
        preserve_split = true,
    },
})


------------------
-- ANIMATIONS
------------------

hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("wind", {
    type = "bezier",
    points = {
        { 0.05, 0.9 },
        { 0.1, 1.05 },
    },
})

hl.curve("easeInOutQuart", {
    type = "bezier",
    points = {
        { 0.76, 0 },
        { 0.24, 1 },
    },
})

hl.curve("winOut", {
    type = "bezier",
    points = {
        { 0.76, 0 },
        { 0.24, 1 },
    },
})

hl.curve("liner", {
    type = "bezier",
    points = {
        { 1, 1 },
        { 1, 1 },
    },
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 6,
    bezier = "wind",
    style = "slide",
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 2.5,
    bezier = "easeInOutQuart",
    style = "slide",
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2.5,
    bezier = "easeInOutQuart",
    style = "slide",
})

hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 2.5,
    bezier = "easeInOutQuart",
    style = "slide",
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 10,
    bezier = "default",
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 5,
    bezier = "wind",
})


------------------
-- KEYBINDINGS
------------------

-- Applications
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/dualsense.sh"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())          -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle

-- Focus movement
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10; workspace 10 is bound to key 0.
for i = 1, 10 do
    local key = i % 10

    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i })
    )

    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i })
    )
end

-- Mouse: move and resize windows.
hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    mainMod .. " + SHIFT + mouse:272",
    hl.dsp.window.resize(),
    { mouse = true }
)

-- Brightness
hl.bind(
    mainMod .. " + CTRL + down",
    hl.dsp.exec_cmd("brightnessctl s 3%-"),
    { repeating = true }
)

hl.bind(
    mainMod .. " + CTRL + up",
    hl.dsp.exec_cmd("brightnessctl s +3%"),
    { repeating = true }
)

-- Volume
hl.bind(
    mainMod .. " + ALT + down",
    hl.dsp.exec_cmd("pamixer -d 3"),
    { repeating = true }
)

hl.bind(
    mainMod .. " + ALT + up",
    hl.dsp.exec_cmd("pamixer -i 3"),
    { repeating = true }
)

hl.bind(
    mainMod .. " + ALT + M",
    hl.dsp.exec_cmd("pamixer -t")
)

-- Waybar
hl.bind(
    mainMod .. " + SHIFT + B",
    hl.dsp.exec_cmd("killall waybar || waybar")
)

-- Screenshots
-- The original config assigned SUPER+SHIFT+S twice.
-- Keep the clipboard-only region screenshot binding.
hl.bind(
    mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd("hyprshot -m region --clipboard-only")
)

hl.bind(
    mainMod .. " + S",
    hl.dsp.exec_cmd("hyprshot -m window")
)

hl.bind(
    "SHIFT + ALT + CTRL + S",
    hl.dsp.exec_cmd("hyprshot -m output")
)

-- Resize tiled/floating windows.
hl.bind(
    mainMod .. " + SHIFT + right",
    hl.dsp.window.resize({ x = 5, y = 0, relative = true }),
    { repeating = true }
)

hl.bind(
    mainMod .. " + SHIFT + left",
    hl.dsp.window.resize({ x = -5, y = 0, relative = true }),
    { repeating = true }
)

hl.bind(
    mainMod .. " + SHIFT + up",
    hl.dsp.window.resize({ x = 0, y = -5, relative = true }),
    { repeating = true }
)

hl.bind(
    mainMod .. " + SHIFT + down",
    hl.dsp.window.resize({ x = 0, y = 5, relative = true }),
    { repeating = true }
)


------------------
-- WINDOW RULES
------------------

-- Ignore maximize requests from all apps.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Float the Wi-Fi / Bluetooth managers opened from waybar.
hl.window_rule({
    name = "float-network-managers",
    match = { class = "^(org.twosheds.iwgtk|io.github.kaii_lb.Overskride)$" },
    float = true,
    size = "720 560",
    center = true,
})

-- Float the WireGuard popup opened from waybar (sizes itself).
hl.window_rule({
    name = "float-wireguard-ui",
    match = { class = "^(local.dotfiles.WireGuard)$" },
    float = true,
    center = true,
})

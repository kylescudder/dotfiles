-- Hyprland 0.55+ Lua configuration.
-- https://wiki.hypr.land/Configuring/Start/

local home = os.getenv("HOME")
local repositories = home .. "/Documents/Repos"
local scripts = repositories .. "/scripts"

local terminal = "ghostty"
local fileManager = "ghostty -e yazi"
local menu = home .. "/.config/rofi/launcher.sh"
local mainMod = "SUPER"

local accent = "rgb(cba6f7)"
local accentSecondary = "rgb(b4befe)"

-- Monitors

hl.monitor({
    output = "DP-2",
    mode = "2560x1440@164.554",
    position = "2560x0",
    scale = 1,
})

hl.monitor({
    output = "DP-3",
    mode = "2560x1440@164.554",
    position = "0x0",
    scale = 1,
})

hl.workspace_rule({ workspace = "1", monitor = "DP-3", default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-2", default = true })
hl.workspace_rule({ workspace = "10", monitor = "DP-3" })

-- Autostart

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("1password --silent")
    hl.exec_cmd("tailscale up")
    hl.exec_cmd("nordvpn connect United_States")
    hl.exec_cmd("systemctl --user start yap.service")
    hl.exec_cmd("lua " .. repositories .. "/plex-directory-scrapper/plex-directory-scapper.lua")
    hl.exec_cmd("nohup " .. scripts .. "/songchange &")
    hl.exec_cmd("spotify-launcher", { workspace = "10 silent" })
    hl.exec_cmd("/usr/bin/ghostty --class=magic-btop -e /usr/bin/btop", {
        workspace = "special:magic silent",
    })
end)

-- Environment

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env(
    "XCURSOR_PATH",
    "/usr/share/icons:/usr/local/share/icons:" .. home .. "/.icons:" .. home .. "/.local/share/icons"
)

-- Appearance and behavior

hl.config({
    ecosystem = {
        no_update_news = true,
    },
    cursor = {
        enable_hyprcursor = false,
    },
    general = {
        gaps_in = 1,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = {
                colors = { accent, accentSecondary },
                angle = 45,
            },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
    input = {
        kb_layout = "us",
        numlock_by_default = true,
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.curve("myBezier", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.05 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- Keybindings

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(
    mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + SHIFT + Delete", hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scripts .. "/speakers"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd(scripts .. "/headphones"))
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.exec_cmd("1password --quick-access"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("yapctl press dictation"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("yapctl release dictation"), { release = true })
hl.bind(mainMod .. " + ALT + D", hl.dsp.exec_cmd("yapctl press command"))
hl.bind(mainMod .. " + ALT + D", hl.dsp.exec_cmd("yapctl release command"), { release = true })

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local lockedRepeating = { locked = true, repeating = true }

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), lockedRepeating)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"), lockedRepeating)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), lockedRepeating)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), lockedRepeating)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), lockedRepeating)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), lockedRepeating)

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Window rules

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "magic-btop-workspace",
    match = { class = "^(magic-btop)$" },
    workspace = "special:magic",
})

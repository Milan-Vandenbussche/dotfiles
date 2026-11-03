-- Host-specific monitor and device rules live outside the shared config.
require("host")

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "wofi"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("theme-apply --restore")
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpm reload -n && hyprctl reload")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "phinger-cursors-dark")

-----------------------
----- PERMISSIONS -----
-----------------------

-- In hyprland.conf, 'enforce_permissions = 1' was placed outside 'ecosystem { ... }',
-- so permission enforcement was inactive. Enabling strict enforcement blocks unpermitted
-- binaries (such as grim for screenshots or hyprpm for plugin loading).
-- It is kept commented out below so behavior matches your functional old config.
-- hl.config({
--     ecosystem = {
--         enforce_permissions = true,
--     },
-- })

-- hl.permission({ binary = "/usr/(bin|local/bin)/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
-- hl.permission({ binary = "/usr/(bin|local/bin)/hyprpm", type = "plugin", mode = "allow" })

-----------------------
---- LOOK AND FEEL ----
-----------------------

local function get_theme_colors()
    local state_dir = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
    local f = io.open(state_dir .. "/theme/generated/colors.json", "r")
    if f then
        local content = f:read("*a")
        f:close()
        local p = content:match('"primary":%s*"#(%x+)"')
        local ov = content:match('"outline_variant":%s*"#(%x+)"')
        if p and ov then
            return "rgb(" .. p .. ")", "rgb(" .. ov .. ")"
        end
    end
    return "rgba(cba6f7ff)", "rgba(313244aa)"
end

local active_col, inactive_col = get_theme_colors()

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 5,

        border_size = 2,

        col = {
            active_border   = active_col,
            inactive_border = inactive_col,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled            = true,
            size               = 6,
            passes             = 3,
            noise              = 0.04,
            contrast           = 1.05,
            brightness         = 0.95,
            vibrancy           = 0.25,
            popups             = true,
            popups_ignorealpha = 0.15,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves from hyprland.conf
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

-- Default animations from hyprland.conf (faithful to old settings)
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = false,
        vrr                     = 1,
    },
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Own binds
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("qs -c shell ipc call wallpaper toggle"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("qs -c shell ipc call audio toggle"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("qs -c shell ipc call network toggle"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("qs -c shell ipc call bluetooth toggle"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs -c shell ipc call launcher toggle"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("screenshot"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("qs -c shell ipc call power toggle"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("systemctl reboot"))

-- Example binds
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("qs -c shell ipc call brightness up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("qs -c shell ipc call brightness down"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

---------------------------------
---- HYPR-DARKWINDOW PLUGIN  ----
---------------------------------

local dw = hl.plugin and hl.plugin.darkwindow
if dw then
    dw.load_shader("transparentNB", {
        path = os.getenv("HOME") .. "/.config/waywall/shaders/NBTracker-transparency.glsl",
        args = { bkg = { 0, 0, 0 }, targetOpacity = 0, similarity = 0.01 },
        introduces_transparency = true,
    })
end

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- suppress-maximize-events
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- fix-xwayland-drags
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- move-hyprland-run
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- Ninjabrain
hl.window_rule({
    name     = "ninjabrain-no-focus",
    match    = { class = "Ninjabrain" },
    no_focus = true,
})

-- Spotify window opacity and blur
hl.window_rule({
    name    = "spotify-opacity",
    match   = { class = "^([sS]potify)$" },
    opacity = "0.85 0.80",
})

-- Steam window opacity and blur
hl.window_rule({
    name    = "steam-opacity",
    match   = { class = "^([sS]team)$" },
    opacity = "0.88 0.82",
})

-- Vesktop / Discord window opacity and blur
hl.window_rule({
    name    = "vesktop-opacity",
    match   = { class = "^([vV]esktop|[dD]iscord)$" },
    opacity = "0.88 0.82",
})






-- waywall
hl.window_rule({
    name        = "waywall-overlay",
    match       = { class = "waywall" },
    border_size = 0,
    rounding    = 0,
    no_blur     = true,
})

-- NBTrackr overlay rules:
-- Uses a small helper to apply identical base rules across title, class, and tag matches.
-- The darkwindow shade is only added if Hypr-DarkWindow is loaded.
local function register_nbtrackr_rule(rule_name, match_table)
    local spec = {
        name        = rule_name,
        match       = match_table,
        float       = true,
        border_size = 0,
        rounding    = 0,
        no_blur     = true,
        pin         = true,
        no_focus    = true,
    }
    if dw then
        spec["darkwindow:shade"] = "transparentNB"
    end
    hl.window_rule(spec)
end

register_nbtrackr_rule("nbtrackr-title", { title = "^(nbtrackr)$" })
register_nbtrackr_rule("nbtrackr-class", { class = "^([nN]btrackr)$" })
register_nbtrackr_rule("nbtrackr-tag",   { tag = "nboverlay" })

-- NOTE: Hyprland layer rules match on 'namespace' (or address), but do NOT match on 'tag'.
-- Window rules support 'tag', whereas layer surfaces only have namespaces.
-- Keeping the original layer rule commented out below as required:
-- hl.layer_rule({
--     name         = "nbtrackr-layer-xray",
--     match        = { tag = "nboverlay" },
--     xray         = true,
--     order        = 10,
--     ignore_alpha = 0.9,
-- })

-- ── Quickshell bar layer blur ──────────────────────────────────────────
hl.layer_rule({
    name         = "qs-bar-blur",
    match        = { namespace = "^(qs-bar)$" },
    blur         = true,
    ignore_alpha = 0.15,
})

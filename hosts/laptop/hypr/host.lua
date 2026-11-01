------------------
---- MONITORS ----
------------------

-- Built-in laptop display, BOE panel.
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1200@60",
    position = "0x0",
    scale    = 1.25,
})

-----------------------
---- INPUT DEVICES ----
-----------------------

-- External mouse used with the laptop.
hl.device({
    name        = "glorious-model-o",
    sensitivity = 0.0,
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

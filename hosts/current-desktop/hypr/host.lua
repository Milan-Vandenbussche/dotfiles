------------------
---- MONITORS ----
------------------

-- AOC 24G2W1G3 - left monitor, DP-3, 165Hz, VRR enabled.
hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@165",
    position = "0x0",
    scale    = 1,
})

-- Samsung S24R35xFZ - right monitor, HDMI-A-1, 75Hz.
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@75",
    position = "1920x0",
    scale    = 1,
})

-----------------------
---- INPUT DEVICES ----
-----------------------

-- Per-device config for the current desktop mouse.
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

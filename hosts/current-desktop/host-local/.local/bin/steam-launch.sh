#!/bin/bash
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1
export DRI_PRIME=1
export MESA_VK_DEVICE_SELECT=10005:0x7480
export STEAM_FORCE_DESKTOPUI_SCALING=1

exec steam -cef-disable-gpu -cef-disable-sandbox "$@"

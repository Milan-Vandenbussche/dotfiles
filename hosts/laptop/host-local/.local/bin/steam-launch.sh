#!/bin/bash
export GDK_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1
export STEAM_FORCE_DESKTOPUI_SCALING=1

exec steam -cef-disable-gpu -cef-disable-sandbox "$@"

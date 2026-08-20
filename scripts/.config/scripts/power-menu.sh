#!/bin/bash
chosen=$(printf "  Power Off\n  Reboot" | wofi --dmenu \
  --prompt "" \
  --style ~/.config/wofi/style.css \
  --width 160 \
  --height 105 \
  --cache-file /dev/null \
  --no-actions)

case "$chosen" in
  "  Power Off") systemctl poweroff ;;
  "  Reboot")    systemctl reboot ;;
esac

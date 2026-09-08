#!/bin/bash
yad --title="Power Menu" \
  --button="Power Off":0 \
  --button="Reboot":1 \
  --buttons-layout=spread \
  --width=160 --height=1 \
  --center \
  --undecorated \
  --fixed \
  --css="$HOME/.config/yad/powermenu.css"

case $? in
  0) systemctl poweroff ;;
  1) systemctl reboot ;;
  # 252 (Escape/closed) and anything else: do nothing
esac

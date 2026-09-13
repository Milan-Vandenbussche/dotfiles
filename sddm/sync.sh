#!/usr/bin/env bash
# Syncs personal SilentSDDM customizations from dotfiles into the live,
# root-owned theme directory. Run after SilentSDDM's ./install.sh has
# populated /usr/share/sddm/themes/silent/ (on a fresh machine or after
# a theme update).
set -euo pipefail

DOTFILES_SDDM="$HOME/dotfiles/sddm"
LIVE_THEME="/usr/share/sddm/themes/silent"

if [[ ! -d "$LIVE_THEME" ]]; then
    echo "Error: $LIVE_THEME not found. Run SilentSDDM's install.sh first."
    exit 1
fi

echo "Syncing config..."
sudo cp "$DOTFILES_SDDM/configs/default.conf" "$LIVE_THEME/configs/default.conf"

echo "Syncing backgrounds..."
sudo cp "$DOTFILES_SDDM/backgrounds/default.jpg" "$LIVE_THEME/backgrounds/default.jpg"
sudo cp "$DOTFILES_SDDM/backgrounds/lonely-homer.mp4" "$LIVE_THEME/backgrounds/lonely-homer.mp4"

sudo chown -R root:root "$LIVE_THEME"

echo "Done. Verify with:"
echo "  QT_IM_MODULE=qtvirtualkeyboard QML2_IMPORT_PATH=$LIVE_THEME/components/ sddm-greeter-qt6 --test-mode --theme $LIVE_THEME"

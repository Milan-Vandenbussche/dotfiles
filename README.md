# Arch Desktop Dotfiles

Reproducible Arch Linux + Hyprland user environment, powered by a handcrafted **Quickshell** desktop shell and dynamic **Material You (Matugen)** system-wide theming.

Symlinks are managed with **GNU Stow**. Each top-level directory corresponds to a stowed package whose paths are relative to `$HOME`.

---

## Architecture & Shell Overview

Legacy status bars, app launchers, and notification daemons (Waybar, Wofi, Dunst, Yad, Blueman, nm-applet) have been fully consolidated into a unified **Quickshell** setup located in [quickshell/.config/quickshell/shell/](quickshell/.config/quickshell/shell/):

| Component | Keybind / Trigger | Description |
| :--- | :--- | :--- |
| **Bar** | *Autostart via uwsm* | Top status bar with dynamic workspace dots, window title, MPRIS media ticker, hardware stats, audio/network/bluetooth status, clock, and notification bell. |
| **App Launcher** | `Super + Space` | Fuzzy application launcher with icon grid, categorizing and launching apps via `uwsm app --`. |
| **Wallpaper Picker** | `Super + W` | Visual wallpaper thumbnail grid sorted by hue, with instant crossfade transitions via `awww` and shuffle button. |
| **Audio Panel** | `Super + A` / Click Bar | PipeWire audio output/input stream selector, volume sliders, and app mixer. |
| **Network Panel** | `Super + N` / Click Bar | Wi-Fi network scanner with WPA PSK passphrase entry and active connection management. |
| **Bluetooth Panel** | `Super + B` / Click Bar | BlueZ device manager with device pairing, connect/disconnect, battery readouts, and discovery mode. |
| **Power Menu** | `Super + F` / Click Bar | Centered power modal with action confirmation (Shut Down, Restart, Log Out via `uwsm stop`, Suspend). |
| **OSD Popups** | Volume / Brightness Keys | Floating on-screen displays for volume and backlight adjustment without pushing tiled windows. |
| **Notifications** | Desktop events / `Super + N` | In-house freedesktop notification server with sliding popup toasts and anchored history panel. |

---

## Dynamic System-Wide Theming (Matugen)

Colors are dynamically derived from your current wallpaper using **Matugen** and applied instantly across the entire system via [theme-apply](local-bin/.local/bin/theme-apply):

```bash
# Apply a new wallpaper and recolor the entire system:
theme-apply /path/to/wallpaper.png

# Restore the theme based on the last selected wallpaper:
theme-apply --restore
```

### Themed Applications & Live Reloading

1. **Quickshell**: Real-time palette reload via `qs ipc call theme reload`.
2. **Hyprland**: Dynamic active window borders and accent colors via `hypr-colors.conf`.
3. **Kitty**: Colors generated to `~/.local/state/theme/generated/kitty-colors.conf` and hot-reloaded via `SIGUSR1`.
4. **btop**: Themed via `~/.config/btop/themes/matugen.theme` with background transparency.
5. **fastfetch**: Automatically inherits the dynamic primary ANSI color from Kitty.
6. **Neovim (LazyVim)**: Dynamic palette loaded via `lua/plugins/theme.lua` with running instance RPC socket reloading.
7. **GTK 3 & GTK 4**: Accent and destructive colors generated to `~/.config/gtk-3.0/gtk.css` and `~/.config/gtk-4.0/gtk.css`.
8. **Prism Launcher**: Custom Qt palette generated to `~/.local/share/PrismLauncher/themes/Matugen/theme.json`.
9. **Spotify**: Styled via Spicetify with transparent background panels and dynamic accent controls.
10. **Vesktop (Discord)**: Powered by the Midnight engine with dual-injected QuickCSS for live recoloring.
11. **Steam**: Styled via Millennium with dynamic primary buttons, game selection, and navigation accents.

### Adding a New Themed Application

To add dynamic Material You theming to any new app:
1. Create a template in `matugen/.config/matugen/templates/<app>.tpl` using Matugen color tokens (e.g., `{{ colors.primary.default.hex }}`).
2. Register the template in [matugen/.config/matugen/config.toml](matugen/.config/matugen/config.toml).
3. Include or reference the generated output in the app's config.
4. Add a live-reload hook to [local-bin/.local/bin/theme-apply](local-bin/.local/bin/theme-apply) (if the app supports reloading without restart).

---

## Bootstrap & First-Run Setup

From a fresh Arch install with your user account:

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
bin/bootstrap.sh
```

### Initial Theme Generation
Before launching Hyprland for the first time, generate the initial color state files:

```bash
~/.local/bin/theme-apply --restore
```

### Host-Specific Profiles
Hardware-dependent settings (monitors, GPU environment variables, device rules) are organized under `hosts/`:
- Desktop: `hosts/current-desktop/hypr/host.lua`
- Laptop: `hosts/laptop/hypr/host.lua`

Apply host configuration:
```bash
DOTFILES_HOST=<host-name> bin/bootstrap.sh --configs-only
```

### Hyprland Plugins & SDDM Setup
```bash
# Hypr-DarkWindow Plugin
hyprpm update
hyprpm add https://github.com/micha4w/Hypr-DarkWindow
hyprpm enable Hypr-DarkWindow
hyprpm reload
```

---

## Refreshing Package Lists

After intentionally installing or removing packages:
```bash
bin/refresh-packages.sh
```

Review git diffs before committing changes.

# Arch Desktop Dotfiles

Plain dotfiles repository for reproducing the current Arch/Hyprland user environment.

This repo uses package folders directly, for example:

```text
hypr/.config/hypr
waybar/.config/waybar
wofi/.config/wofi
kitty/.config/kitty
```

GNU Stow manages the symlinks. Each top-level package folder contains paths relative to `$HOME`, so `waybar/.config/waybar` becomes `~/.config/waybar` when stowed.

## What This Restores

- Explicit official packages from `packages/pacman-explicit.txt`
- Explicit AUR packages from `packages/aur-explicit.txt`
- Hyprland, Waybar, Wofi, Kitty, UWSM, Fastfetch, Btop, Htop, CopyQ, shell settings, GTK settings, MIME associations, and user scripts
- Desktop launchers and Wayland flags for Discord, Brave, and Steam
- The selected wallpaper at `~/.local/share/wallpapers/wallhaven-6l5emq.png`
- The Waywall config repo pinned in `waywall.lock`

Browsers, OBS, LibreOffice, Discord, and other desktop apps are installed through the package manifests. Their profiles and runtime state are intentionally not committed.

The repository includes `git/.gitconfig`, which contains the current Git name and email, but never GitHub authentication. Authenticate GitHub CLI separately with `gh auth login` on each new machine.

## Bootstrap

From a fresh Arch install with a normal user account:

```bash
git clone <private-github-repo-url> ~/dotfiles
cd ~/dotfiles
bin/bootstrap.sh
```

Useful options:

```bash
bin/bootstrap.sh --configs-only
bin/bootstrap.sh --packages-only
bin/bootstrap.sh --host current-desktop
```

The bootstrap backs up conflicting live files before asking Stow to create the links. The backup directory is:

```text
~/.local/state/dotfiles-backup/<timestamp>/
```

To apply only configuration symlinks after GNU Stow is installed:

```bash
bin/bootstrap.sh --configs-only
```

## Host-Specific Hyprland Config

The shared Hyprland config sources:

```text
~/.config/hypr/host.conf
```

The current desktop profile lives at:

```text
hosts/current-desktop/hypr/host.conf
```

That file contains hardware-specific settings such as monitor names, refresh rates, positions, and the current mouse device rule. For another machine, add a new folder under `hosts/` and run:

```bash
DOTFILES_HOST=<new-host> bin/bootstrap.sh --configs-only
```

The Steam launcher is also host-specific because the current desktop has GPU-selection environment variables. Copy and adapt `hosts/current-desktop/host-local/.local/bin/steam-launch.sh` for another computer, or omit it to use Steam's standard launcher.

## Refresh Package Lists

After installing or removing packages intentionally:

```bash
bin/refresh-packages.sh
```

Review the diff before committing.

## Before Pushing

Run:

```bash
bin/check-secrets.sh
git status --short
```

`check-secrets.sh` is a simple grep-style guard. It does not prove the repo is secret-free, so still review changes before pushing.

Create the private GitHub repo with:

```bash
gh repo create dotfiles --private --source=. --remote=origin --push
```


### FIX HYPRLAND PLUGIN ON PACKAGE UPDATE

hyprpm update
#hyprpm purge-cache
hyprpm add https://github.com/micha4w/Hypr-DarkWindow
hyprpm enable Hypr-DarkWindow
hyprpm reload

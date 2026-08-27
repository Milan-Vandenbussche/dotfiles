#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
HOST_PROFILE="${DOTFILES_HOST:-current-desktop}"
BACKUP_ROOT="${XDG_STATE_HOME:-"$HOME/.local/state"}/dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

PACKAGES=(
  applications
  btop
  copyq
  desktop
  fastfetch
  git
  htop
  hypr
  kitty
  local-bin
  scripts
  shell
  uwsm
  waybar
  wallpaper
  wofi
)

usage() {
  sed -n '2,80p' "$REPO_ROOT/README.md"
}

read_manifest() {
  local manifest="$1"
  sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$manifest"
}

install_official_packages() {
  local manifest="$REPO_ROOT/packages/pacman-explicit.txt"

  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman was not found; this bootstrap is intended for Arch Linux." >&2
    return 1
  fi

  mapfile -t packages < <(read_manifest "$manifest")
  if ((${#packages[@]})); then
    sudo pacman -S --needed "${packages[@]}"
  fi
}

ensure_stow() {
  if ! command -v stow >/dev/null 2>&1; then
    echo "GNU Stow is required for config installation. Install the stow package first." >&2
    return 1
  fi
}

backup_stow_conflicts() {
  local package_dir="$1"
  local package_name="$2"

  while IFS= read -r -d '' source; do
    local rel="${source#"$package_dir"/}"
    local target="$HOME/$rel"

    if [[ ! -e "$target" && ! -L "$target" ]]; then
      continue
    fi

    if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
      continue
    fi

    local backup="$BACKUP_ROOT/$rel"
    mkdir -p -- "$(dirname -- "$backup")"
    mv -- "$target" "$backup"
    echo "Backed up $target to $backup before stowing $package_name"
  done < <(find "$package_dir" \( -type f -o -type l \) -print0)
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    return
  fi

  local build_dir
  build_dir="$(mktemp -d)"

  git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
  (cd "$build_dir/yay" && makepkg -si)
}

install_aur_packages() {
  local manifest="$REPO_ROOT/packages/aur-explicit.txt"

  ensure_yay

  mapfile -t packages < <(read_manifest "$manifest")
  if ((${#packages[@]})); then
    yay -S --needed "${packages[@]}"
  fi
}

select_host() {
  local host_conf="$REPO_ROOT/hosts/$HOST_PROFILE/hypr/host.conf"
  local package_host_conf="$REPO_ROOT/hypr/.config/hypr/host.conf"

  if [[ ! -f "$host_conf" ]]; then
    echo "Host profile not found: $host_conf" >&2
    return 1
  fi

  ln -sfn -- "../../../hosts/$HOST_PROFILE/hypr/host.conf" "$package_host_conf"
}

install_steam_desktop() {
  local template="$REPO_ROOT/templates/steam.desktop.in"
  local target="$HOME/.local/share/applications/steam.desktop"

  [[ -f "$template" ]] || return

  if [[ -e "$target" || -L "$target" ]]; then
    if ! grep -qx 'X-Dotfiles-Managed=true' "$target" 2>/dev/null; then
      local backup="$BACKUP_ROOT/.local/share/applications/steam.desktop"
      mkdir -p -- "$(dirname -- "$backup")"
      mv -- "$target" "$backup"
      echo "Backed up $target to $backup"
    fi
  fi

  mkdir -p -- "$(dirname -- "$target")"
  sed "s|@HOME@|$HOME|g" "$template" > "$target"
}

install_waywall_config() {
  local lock_file="$REPO_ROOT/waywall.lock"
  local remote
  local revision

  remote="$(sed -n 's/^remote=//p' "$lock_file")"
  revision="$(sed -n 's/^revision=//p' "$lock_file")"

  if [[ -z "$remote" || -z "$revision" ]]; then
    echo "Invalid waywall.lock" >&2
    return 1
  fi

  if [[ -d "$HOME/.config/waywall/.git" ]]; then
    git -C "$HOME/.config/waywall" fetch --all --prune
    git -C "$HOME/.config/waywall" checkout "$revision"
    return
  fi

  if [[ -e "$HOME/.config/waywall" ]]; then
    local backup="$BACKUP_ROOT/.config/waywall"
    mkdir -p -- "$(dirname -- "$backup")"
    mv -- "$HOME/.config/waywall" "$backup"
    echo "Backed up $HOME/.config/waywall to $backup"
  fi

  git clone "$remote" "$HOME/.config/waywall"
  git -C "$HOME/.config/waywall" checkout "$revision"
}

install_dotfiles() {
  ensure_stow
  select_host

  for package in "${PACKAGES[@]}"; do
    backup_stow_conflicts "$REPO_ROOT/$package" "$package"
    stow --dir="$REPO_ROOT" --target="$HOME" --restow "$package"
  done

  backup_stow_conflicts "$REPO_ROOT/hosts/$HOST_PROFILE/host-local" "host-local"
  stow --dir="$REPO_ROOT/hosts/$HOST_PROFILE" --target="$HOME" --restow host-local
  install_steam_desktop
  install_waywall_config
}

main() {
  local install_packages=1
  local install_configs=1

  while (($#)); do
    case "$1" in
      --configs-only)
        install_packages=0
        ;;
      --packages-only)
        install_configs=0
        ;;
      --host)
        HOST_PROFILE="${2:?missing host profile name}"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        exit 2
        ;;
    esac
    shift
  done

  if ((install_packages)); then
    install_official_packages
    install_aur_packages
  fi

  if ((install_configs)); then
    install_dotfiles
  fi

  echo "Bootstrap complete."
}

main "$@"

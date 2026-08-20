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

link_item() {
  local source="$1"
  local target="$2"
  local rel="${target#"$HOME"/}"

  mkdir -p -- "$(dirname -- "$target")"

  if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local backup="$BACKUP_ROOT/$rel"
    mkdir -p -- "$(dirname -- "$backup")"
    mv -- "$target" "$backup"
    echo "Backed up $target to $backup"
  fi

  ln -s -- "$source" "$target"
}

link_package() {
  local package="$1"
  local source_root="$REPO_ROOT/$package"

  while IFS= read -r -d '' source; do
    local rel="${source#"$source_root"/}"
    local target="$HOME/$rel"

    if [[ -d "$source" && ! -L "$source" ]]; then
      mkdir -p -- "$target"
    else
      link_item "$source" "$target"
    fi
  done < <(find "$source_root" -mindepth 1 -print0)
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

link_host_files() {
  local source_root="$REPO_ROOT/hosts/$HOST_PROFILE/.local"

  [[ -d "$source_root" ]] || return

  while IFS= read -r -d '' source; do
    local rel="${source#"$source_root"/}"
    local target="$HOME/.local/$rel"

    if [[ -d "$source" && ! -L "$source" ]]; then
      mkdir -p -- "$target"
    else
      link_item "$source" "$target"
    fi
  done < <(find "$source_root" -mindepth 1 -print0)
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

install_wallpaper() {
  link_item \
    "$REPO_ROOT/assets/wallpapers/wallhaven-6l5emq.png" \
    "$HOME/.local/share/wallpapers/wallhaven-6l5emq.png"
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
  select_host
  install_wallpaper

  for package in "${PACKAGES[@]}"; do
    link_package "$package"
  done

  link_host_files
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

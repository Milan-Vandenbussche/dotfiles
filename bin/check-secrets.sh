#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

SCAN_PATHS=(
  "$REPO_ROOT/btop"
  "$REPO_ROOT/copyq"
  "$REPO_ROOT/desktop"
  "$REPO_ROOT/fastfetch"
  "$REPO_ROOT/git"
  "$REPO_ROOT/hosts"
  "$REPO_ROOT/htop"
  "$REPO_ROOT/hypr"
  "$REPO_ROOT/kitty"
  "$REPO_ROOT/local-bin"
  "$REPO_ROOT/packages"
  "$REPO_ROOT/scripts"
  "$REPO_ROOT/shell"
  "$REPO_ROOT/templates"
  "$REPO_ROOT/uwsm"
  "$REPO_ROOT/waybar"
  "$REPO_ROOT/wofi"
)

if rg --hidden -n -i \
  'password|passwd|token|secret|api[_-]?key|private[ _-]?key|BEGIN (OPENSSH|RSA|DSA|EC|PGP) PRIVATE KEY' \
  "${SCAN_PATHS[@]}"; then
  echo "Potential secret detected; review the matches above." >&2
  exit 1
fi

echo "No potential secrets found."

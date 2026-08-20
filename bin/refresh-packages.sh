#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

pacman -Qqen > "$REPO_ROOT/packages/pacman-explicit.txt"
pacman -Qqem > "$REPO_ROOT/packages/aur-explicit.txt"

git -C "$REPO_ROOT" diff -- packages/pacman-explicit.txt packages/aur-explicit.txt

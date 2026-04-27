#!/usr/bin/env bash
set -euo pipefail

theme_repo="https://github.com/vinceliuice/Colloid-gtk-theme.git"
theme_dir="${HOME}/.themes"
work_dir="$(mktemp -d)"
cleanup() {
    rm -rf "$work_dir"
}
trap cleanup EXIT

if ! command -v git >/dev/null 2>&1; then
    echo "git is required to install Colloid."
    exit 1
fi

if ! command -v sassc >/dev/null 2>&1; then
    echo "sassc is required to install Colloid. Run ./scripts/install-prereqs.sh first."
    exit 1
fi

mkdir -p "$theme_dir"

git clone --depth=1 "$theme_repo" "$work_dir/Colloid-gtk-theme"
"$work_dir/Colloid-gtk-theme/install.sh" \
    -d "$theme_dir" \
    -c dark \
    -s compact \
    --tweaks rimless normal

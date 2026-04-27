#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v dconf >/dev/null 2>&1; then
    echo "dconf is not available; skipping dconf imports."
    exit 0
fi

dconf load /org/gnome/terminal/ < "$repo_root/gnome/gnome-terminal.dconf"
dconf load /org/gnome/desktop/wm/keybindings/ < "$repo_root/gnome/wm-keys.dconf"
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$repo_root/gnome/media-keys.dconf"

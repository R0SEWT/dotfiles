#!/usr/bin/env bash
set -euo pipefail

extensions=(
    "ding@rastersoft.com"
    "ubuntu-dock@ubuntu.com"
    "tiling-assistant@ubuntu.com"
)

if ! command -v gnome-extensions >/dev/null 2>&1; then
    echo "gnome-extensions is not available; skipping extension enablement."
    exit 0
fi

for extension in "${extensions[@]}"; do
    if gnome-extensions info "$extension" >/dev/null 2>&1; then
        gnome-extensions enable "$extension" >/dev/null 2>&1 || true
    else
        echo "Skipping missing extension: $extension"
    fi
done

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
desktop=false

while (($# > 0)); do
    case "$1" in
        --desktop)
            desktop=true
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--desktop]"
            exit 1
            ;;
    esac
    shift
done

echo "==> Ensuring local fonts are available"
"$repo_root/scripts/fonts.sh"

if [ "$desktop" = true ]; then
    echo "==> Installing Colloid GTK theme"
    "$repo_root/scripts/install-colloid-theme.sh"

    echo "==> Applying GNOME desktop settings"
    "$repo_root/scripts/extensions.sh"
    "$repo_root/scripts/gsettings.sh"
    "$repo_root/scripts/dconf-load.sh"
fi

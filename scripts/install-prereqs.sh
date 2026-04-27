#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
packages_file="$repo_root/packages/apt.txt"
npm_packages_file="$repo_root/packages/npm-global.txt"

if ! command -v apt-get >/dev/null 2>&1; then
    echo "This bootstrap currently supports apt-based systems only."
    exit 1
fi

mapfile -t packages < <(grep -Ev '^\s*($|#)' "$packages_file")

echo "==> Updating apt metadata"
sudo apt-get update

if ((${#packages[@]} > 0)); then
    echo "==> Installing packages from $packages_file"
    sudo apt-get install -y "${packages[@]}"
fi

if command -v npm >/dev/null 2>&1 && [ -f "$npm_packages_file" ]; then
    mapfile -t npm_packages < <(grep -Ev '^\s*($|#)' "$npm_packages_file")
    if ((${#npm_packages[@]} > 0)); then
        echo "==> Installing global npm tools from $npm_packages_file"
        npm install -g "${npm_packages[@]}"
    fi
fi

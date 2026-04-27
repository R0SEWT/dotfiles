#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
default_packages=(bash zsh shell fish git gh gtk terminal vscode)

if ! command -v stow >/dev/null 2>&1; then
    echo "stow is not installed."
    exit 1
fi

if (($# == 0)); then
    packages=("${default_packages[@]}")
else
    packages=("$@")
fi

cd "$repo_root"
stow --target="$HOME" --delete "${packages[@]}"

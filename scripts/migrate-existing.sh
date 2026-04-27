#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backup_root="$HOME/.local/state/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

targets=(
    ".bashrc"
    ".profile"
    ".zshrc"
    ".local/bin/env"
    ".local/bin/env.fish"
    ".config/fish/config.fish"
    ".config/fish/conf.d/uv.env.fish"
    ".gitconfig"
    ".config/gh/config.yml"
    ".config/ghostty/config"
    ".config/btop/btop.conf"
    ".config/Code/User/settings.json"
    ".config/Code/User/keybindings.json"
    ".config/Code/User/mcp.json"
)

mkdir -p "$backup_root"

for relpath in "${targets[@]}"; do
    target="$HOME/$relpath"

    if [ -L "$target" ]; then
        continue
    fi

    if [ -e "$target" ]; then
        mkdir -p "$backup_root/$(dirname "$relpath")"
        mv "$target" "$backup_root/$relpath"
        echo "Backed up $relpath -> $backup_root/$relpath"
    fi
done

if command -v stow >/dev/null 2>&1; then
    "$repo_root/scripts/stow.sh"
else
    "$repo_root/scripts/link-home.sh"
fi

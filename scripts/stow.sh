#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
default_packages=(bash zsh shell fish git gh terminal vscode)

if ! command -v stow >/dev/null 2>&1; then
    echo "stow is not installed. Run ./scripts/install-prereqs.sh first."
    exit 1
fi

if (($# == 0)); then
    packages=("${default_packages[@]}")
else
    packages=("$@")
fi

normalize_managed_symlinks() {
    local package package_dir relpath target_path resolved_path

    for package in "${packages[@]}"; do
        package_dir="$repo_root/$package"
        [ -d "$package_dir" ] || continue

        while IFS= read -r relpath; do
            relpath="${relpath#./}"
            target_path="$HOME/$relpath"

            if [ -L "$target_path" ]; then
                resolved_path="$(readlink -f "$target_path")"
                case "$resolved_path" in
                    "$repo_root"/*)
                        rm -f "$target_path"
                        ;;
                esac
            fi
        done < <(cd "$package_dir" && find . \( -type f -o -type l \) | sort)
    done
}

normalize_managed_symlinks

cd "$repo_root"
stow --target="$HOME" --restow "${packages[@]}"

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
default_packages=(bash zsh shell fish git gh terminal vscode)

if (($# == 0)); then
    packages=("${default_packages[@]}")
else
    packages=("$@")
fi

for package in "${packages[@]}"; do
    package_dir="$repo_root/$package"

    if [ ! -d "$package_dir" ]; then
        echo "Skipping missing package: $package"
        continue
    fi

    while IFS= read -r relpath; do
        relpath="${relpath#./}"
        source_path="$package_dir/$relpath"
        target_path="$HOME/$relpath"

        mkdir -p "$(dirname "$target_path")"

        if [ -L "$target_path" ]; then
            rm -f "$target_path"
        elif [ -e "$target_path" ]; then
            echo "Refusing to overwrite non-symlink target: $target_path"
            exit 1
        fi

        ln -s "$source_path" "$target_path"
    done < <(cd "$package_dir" && find . \( -type f -o -type l \) | sort)
done

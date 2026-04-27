#!/usr/bin/env bash
set -euo pipefail

missing_packages=()

if ! fc-list | grep -qi "JetBrains Mono"; then
    missing_packages+=("fonts-jetbrains-mono")
fi

if ! fc-list | grep -qi "Inter"; then
    missing_packages+=("fonts-inter")
fi

if ((${#missing_packages[@]} > 0)); then
    sudo apt-get install -y "${missing_packages[@]}"
fi

fc-cache -f >/dev/null 2>&1 || true

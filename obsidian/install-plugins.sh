#!/usr/bin/env bash
set -euo pipefail

VAULT="$HOME/notes"
PLUGINS_DIR="$VAULT/.obsidian/plugins"
THEMES_DIR="$VAULT/.obsidian/themes"

declare -A PLUGINS=(
  [dataview]="blacksmithgu/obsidian-dataview"
  [templater-obsidian]="SilentVoid13/Templater"
  [obsidian-style-settings]="mgmeyers/obsidian-style-settings"
)

THEME_REPO="catppuccin/obsidian"

install_plugin() {
  local id="$1" repo="$2"
  local dir="$PLUGINS_DIR/$id"

  if [[ -d "$dir" ]]; then
    echo "  skip: $id (already installed)"
    return
  fi

  echo "  installing: $id"
  local release
  release=$(curl -sL "https://api.github.com/repos/$repo/releases/latest")

  local tag
  tag=$(echo "$release" | grep -m1 '"tag_name"' | cut -d'"' -f4)

  mkdir -p "$dir"

  for file in main.js manifest.json styles.css; do
    local url="https://github.com/$repo/releases/download/$tag/$file"
    if curl -sfL "$url" -o "$dir/$file" 2>/dev/null; then
      :
    else
      rm -f "$dir/$file"
    fi
  done

  if [[ ! -f "$dir/main.js" ]]; then
    echo "    WARNING: main.js not found for $id"
    rm -rf "$dir"
    return 1
  fi

  echo "    done ($tag)"
}

install_theme() {
  local dir="$THEMES_DIR/Catppuccin"

  if [[ -d "$dir" ]]; then
    echo "  skip: Catppuccin theme (already installed)"
    return
  fi

  echo "  installing: Catppuccin theme"
  mkdir -p "$dir"

  local release
  release=$(curl -sL "https://api.github.com/repos/$THEME_REPO/releases/latest")
  local tag
  tag=$(echo "$release" | grep -m1 '"tag_name"' | cut -d'"' -f4)

  curl -sfL "https://github.com/$THEME_REPO/releases/download/$tag/theme.css" \
    -o "$dir/theme.css"
  curl -sfL "https://github.com/$THEME_REPO/releases/download/$tag/manifest.json" \
    -o "$dir/manifest.json"

  echo "    done ($tag)"
}

echo "=== Obsidian Plugin Installer ==="
echo ""
echo "Plugins:"
for id in "${!PLUGINS[@]}"; do
  install_plugin "$id" "${PLUGINS[$id]}"
done

echo ""
echo "Theme:"
install_theme

echo ""
echo "Done. Open Obsidian and enable community plugins in Settings."

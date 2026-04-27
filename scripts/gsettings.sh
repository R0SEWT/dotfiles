#!/usr/bin/env bash
set -euo pipefail

if ! command -v gsettings >/dev/null 2>&1; then
    echo "gsettings is not available; skipping desktop settings."
    exit 0
fi

set_key() {
    local schema="$1"
    local key="$2"
    local value="$3"

    if gsettings writable "$schema" "$key" >/dev/null 2>&1; then
        gsettings set "$schema" "$key" "$value"
    else
        echo "Skipping $schema::$key (schema or key unavailable)"
    fi
}

set_key org.gnome.desktop.interface gtk-theme "'Adwaita-dark'"
set_key org.gnome.desktop.wm.preferences theme "'Adwaita-dark'"
set_key org.gnome.desktop.interface icon-theme "'Papirus-Dark'"
set_key org.gnome.desktop.interface font-name "'Inter 11'"
set_key org.gnome.desktop.interface document-font-name "'Inter 11'"
set_key org.gnome.desktop.interface monospace-font-name "'JetBrains Mono 11'"
set_key org.gnome.desktop.interface cursor-theme "'Bibata-Modern-Classic'"
set_key org.gnome.desktop.interface enable-animations "false"
set_key org.gnome.shell.extensions.dash-to-dock dock-fixed "false"
set_key org.gnome.shell.extensions.dash-to-dock extend-height "false"
set_key org.gnome.shell.extensions.dash-to-dock transparency-mode "'DYNAMIC'"

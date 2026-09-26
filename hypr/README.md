# Hyprland

Configuración personalizada de Hyprland sobre [JaKooLit dots](https://github.com/JaKooLit). Solo se gestionan aquí los archivos de usuario (`UserConfigs/`, `hyprland.conf`, `hypridle.conf`); los scripts y configs default de JaKooLit se mantienen in-place.

## Instalación

```bash
cd ~/dotfiles
stow hypr
```

## Archivos

- `hyprland.conf` — config principal, sourcea los UserConfigs y configs default
- `hypridle.conf` — timeouts de idle (lock, dpms off)
- `UserConfigs/` — settings personalizados (input, gestos, keybinds, decoraciones, etc.)

## Notas

- `monitors.conf` y `workspaces.conf` son auto-generados por nwg-displays y no se gestionan aquí.
- Los scripts en `~/.config/hypr/scripts/` y `~/.config/hypr/configs/` son de JaKooLit y se actualizan con `upgrade.sh`.

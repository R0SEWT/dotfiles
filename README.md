# 💻 Mis Dotfiles

Este repositorio contiene mis archivos de configuración personales para sistemas Linux. Utilizo **[GNU Stow](https://www.gnu.org/software/stow/)** para gestionar los enlaces simbólicos (symlinks) e instalar estas configuraciones fácilmente en cualquier máquina.

## Configuraciones Disponibles

Actualmente este repositorio incluye:

- **[EasyEffects](./easyeffects/)**: Presets orientados al diagnóstico, estabilización y compensación de sistemas de audio (PipeWire).
- **[Windows VM](./windows-vm/)**: Script y configuración base para levantar una VM local de Windows con QEMU/KVM y `swtpm`.
- **[AI accounts](./ai-accounts/)**: `claude-as` / `codex-as` / `ai-cuota` para rotar cuentas de Claude Code y Codex.
- **[Hyprland](./hypr/)**: config en Lua (`hyprland.lua` + `lua/`, Hyprland ≥ 0.56) sobre los dots de KooL, más los scripts de KooL adaptados a ella. Los `.conf` quedan solo como vuelta atrás.
- **[Wallust](./wallust/)**: `wallust.toml` y plantillas de colores; genera `~/.config/hypr/wallust/colors.lua` para Hyprland.
- **[Waybar](./waybar/)** / **[SwayNC](./swaync/)**: solo los archivos que llaman a `hyprctl dispatch` (sintaxis Lua); el resto sigue siendo de KooL sin versionar.

*(Aquí puedes añadir más en el futuro: bash/zsh, nvim, git, tmux, etc.)*

## Instalación y Uso

### Prerrequisitos
Asegúrate de tener instalado `git` y `stow` en la distro.

```bash
sudo apt install git stow
```

### Clonar el repositorio

```bash
git clone git@github.com:R0SEWT/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Aplicar las configuraciones
Para enlazar una configuración concreta (por ejemplo, `easyeffects`), simplemente ejecuta `stow` pasando el nombre del directorio:

```bash
stow easyeffects
```

Para instalar el lanzador de la VM de Windows:

```bash
stow windows-vm
```

Esto creará automáticamente los symlinks necesarios en la estructura de tu directorio home/configuración.

Para quitar una configuración (deshacer el symlink):
```bash
stow -D easyeffects
```

## Arquitectura y Decisiones (ADRs)
Ver la carpeta `docs/adr/` para entender las decisiones técnicas de este repositorio. Información y reglas para agentes IA se encuentran en `.github/copilot-instructions.md`.

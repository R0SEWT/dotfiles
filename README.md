# 💻 Mis Dotfiles

Este repositorio contiene mis archivos de configuración personales para sistemas Linux. Utilizo **[GNU Stow](https://www.gnu.org/software/stow/)** para gestionar los enlaces simbólicos (symlinks) e instalar estas configuraciones fácilmente en cualquier máquina.

## Configuraciones Disponibles

Actualmente este repositorio incluye:

- **[EasyEffects](./easyeffects/)**: Presets orientados al diagnóstico, estabilización y compensación de sistemas de audio (PipeWire).

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

Esto creará automáticamente los symlinks necesarios en la estructura de tu directorio home/configuración.

Para quitar una configuración (deshacer el symlink):
```bash
stow -D easyeffects
```

## Arquitectura y Decisiones (ADRs)
Ver la carpeta `docs/adr/` para entender las decisiones técnicas de este repositorio. Información y reglas para agentes IA se encuentran en `.github/copilot-instructions.md`.

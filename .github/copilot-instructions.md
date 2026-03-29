# Dotfiles Repository Instructions

Este archivo define las reglas y convenciones para agentes de IA (como GitHub Copilot) que asistan en este repositorio de dotfiles.

## Reglas de Arquitectura y Estructura

1.  **Modularidad Estricta:** Cada herramienta o entorno debe tener su propia carpeta en la raíz (ej. `easyeffects/`, `zsh/`, `nvim/`).
2.  **No Scripts Globales:** NO crear scripts monolíticos tipo `install.sh` o `setup.sh` que instalen todo el repositorio.
3.  **Gestión Exclusiva con GNU Stow:** Todas las instalaciones se realizan mediante comandos manuales de `stow`. Asume siempre que la estructura interna de cada carpeta debe ser compatible con la creación de symlinks de Stow hacia el directorio `$HOME`.
4.  **Documentación Descentralizada:** Cada módulo debe tener su propio `README.md` explicando qué configuraciones incluye y cualquier paso específico para ese módulo, complementando al `README.md` principal.
5.  **ADRs (Architecture Decision Records):** Cualquier cambio fundamental en cómo se gestionan los dotfiles (ej. cambiar Stow por otra herramienta, cambiar la estructura de ramas) debe registrarse como un nuevo documento en `docs/adr/`.

## Flujo de Trabajo

- Al añadir una nueva configuración, crea la carpeta correspondiente, añade los archivos replicando la estructura del `$HOME` (ej. `mimodulo/.config/mimodulo/archivo.conf`), y actualiza la lista en el `README.md` principal.
- Respeta siempre el enfoque pragmático y minimalista de la documentación: "directo al grano".

# dotfiles

Configuración personal de Linux gestionada con [GNU Stow](https://www.gnu.org/software/stow/). **Cada máquina vive en su propia rama `host/*`**; `main` solo documenta el modelo.

## Ramas

| Rama | Máquina | Entorno |
|---|---|---|
| `host/cip-zorark` | laptop de trabajo | Ubuntu 24.04 + GNOME, fish |
| `host/cip-exodia` | exodia | deriva de `host/cip-zorark` |
| `host/dell-fedora` | Dell personal | Fedora + Hyprland, zsh |

Otras ramas: `feat/*` para cambios que sirven a más de una máquina, `agent/*` para trabajo en curso de agentes.

## Flujo

- **Cambio de una sola máquina** → commit directo en su `host/*`.
- **Cambio que sirve a varias** → rama `feat/<tema>` desde la `host/*` donde nace; luego se integra en cada `host/*` que lo quiera:
  - `git merge feat/<tema>` si comparten historia (`host/cip-zorark` ↔ `host/cip-exodia`);
  - cherry-pick o copia del paquete si no (`host/dell-fedora` tiene historia propia desde 2026-03-29).
- **No mergear una `host/*` en otra**: arrastra la configuración de la otra máquina.
- Un paquete compartido (p. ej. `ai-accounts/`) se mantiene idéntico en todas las ramas que lo usan, para que los siguientes cambios entren limpios.
- Lo que varía entre máquinas dentro de un paquete (rutas, credenciales) va en overlays no versionados (`*.local`, `secrets.zsh`), no en el archivo compartido.

## Máquina nueva

```bash
git clone -b host/<máquina> https://github.com/R0SEWT/dotfiles.git
```

Si la máquina aún no tiene rama, créala desde la más parecida y súbela:

```bash
git switch -c host/<nueva> origin/host/<la-más-parecida>
git push -u origin host/<nueva>
```

Cada rama explica en su `README.md` qué paquetes trae y cómo stowearlos.

## Pendiente

`main` queda por ahora como este README. Si más adelante reúne paquetes comunes, pasaría a ser la base que cada `host/*` mergea (`feat/* → main → host/*`), y esa decisión se registrará como ADR. Hoy `main` no comparte historia con las `host/*`: el primer merge en cada una necesitaría `--allow-unrelated-histories`.

# ai-accounts

Rotación de cuentas para Claude Code y Codex CLI. Cada perfil tiene su propio login y comparte el resto (memoria, plugins, skills, settings, hooks) con `~/.claude` / `~/.codex` por symlink.

| Script | Qué hace |
|---|---|
| `claude-as <perfil> [args]` | `claude` con `CLAUDE_CONFIG_DIR` del perfil (`cip` → `~/.claude`, `rody` → `~/.claude-account-2`, `personal` → `~/.claude-personal`) |
| `codex-as <perfil> [args]` | `codex` con `CODEX_HOME` del perfil (`team` → `~/.codex`, `secondary` → `~/.codex-secondary`) |
| `ai-cuota status\|pick claude\|codex` | cuota libre por perfil vía la API de uso (solo lectura, nunca refresca tokens); lo usan `status` y `auto` |

Subcomandos comunes: `list` (estado de login), `status` (cuota Session/Weekly), `auto [args]` (abre la cuenta con más margen; prefiere la por defecto mientras tenga ≥20 %), `link <perfil>` (rehace los symlinks compartidos y respalda copias propias en `backups/`).

## Instalación

Desde la raíz del repo, en cualquier rama `host/*`:

```bash
mkdir -p ~/.local/bin
stow --target="$HOME" ai-accounts
```

Requiere `bash` ≥ 4, `python3`, `claude` y/o `codex` en el `PATH`, y `~/.local/bin` en el `PATH`.

- El `mkdir` importa: si `~/.local` no existe, stow enlaza la carpeta entera al repo y todo lo que se escriba en `~/.local/share` acabaría dentro del repo.
- Si ya había copias reales en `~/.local/bin`, stow choca: muévelas fuera antes de stowear.

## Máquina nueva

Los logins no viajan con el repo. Por cada perfil:

```bash
claude-as rody auth login        # crea ~/.claude-account-2 y enlaza lo compartido
codex-as secondary login
claude-as list && codex-as list
```

El perfil por defecto (`cip` / `team`) es el login normal de `claude` / `codex`. Un perfil sin login aparece con `?` en `status` y `auto` no lo elige.

## Notas

- Para agregar o renombrar un perfil hay que tocar tres sitios: `DIRS` y el bucle de `list` en `claude-as` / `codex-as`, y `PROFILES` en `ai-cuota`.
- Si el token de un perfil venció, `ai-cuota` cae a la caché de CrossUsage (`~/.local/share/com.barramee27.crossusage/usage-api-cache.json`) cuando tiene <30 min; sin CrossUsage, muestra `?` hasta que abras el perfil una vez.
- No copies `.credentials.json` ni `auth.json` entre perfiles, máquinas o CrossUsage: los refresh tokens rotan y la copia invalida la sesión original. Login propio en cada sitio.

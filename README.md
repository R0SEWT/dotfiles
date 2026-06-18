# Dotfiles

Reproducible workstation setup for Ubuntu 24.04 with GNU Stow.

This repository manages the stable parts of the environment:

- Shell: `bash`, `zsh`, `fish`, shared local PATH bootstraps
- Git: base config plus a private local identity overlay
- CLI apps: `gh`, `ghostty`, `btop`
- Editor: VS Code user settings, keybindings, and MCP config
- Audio: EasyEffects (PipeWire) output presets for diagnostics, stabilization, and tuning
- Optional desktop overlay: GNOME themes, fonts, terminal tweaks, and enabled extensions
- Colloid GTK theme for a tighter GNOME window/titlebar look
- Local ticketing with `bd` (Beads) for repo-scoped work tracking

## Layout

- `bash/`, `zsh/`, `shell/`, `fish/`: shell startup files
- `gtk/`: user GTK overrides for titlebar and control styling
- `git/`: public Git defaults
- `gh/`: GitHub CLI non-secret config
- `terminal/`: terminal app configs
- `vscode/`: VS Code user config
- `easyeffects/`: EasyEffects output presets (PipeWire)
- `packages/`: package lists
- `scripts/`: bootstrap and maintenance scripts
- `gnome/`: optional desktop exports for GNOME
- `examples/`: local-only overlay examples
- `.beads/`: repo-local ticket data after initialization
- `docs/adr/`: architecture decision records
- `.github/copilot-instructions.md`: rules and context for AI agents

## First-time setup on a new machine

```bash
git clone <your-repo-url> ~/Code/dotfiles
cd ~/Code/dotfiles
./scripts/install-prereqs.sh
cp examples/gitconfig.local.example ~/.gitconfig.local
./scripts/stow.sh
./scripts/bootstrap.sh --desktop
gh auth login
```

If you do not want the GNOME layer, skip `--desktop`.
If `stow` is not available yet, `./scripts/migrate-existing.sh` falls back to plain symlinks for the current machine.

## Day-to-day usage

Restow everything after changing tracked files:

```bash
./scripts/stow.sh
```

`fish` is the primary interactive shell in this setup. Its prompt is intentionally minimal and repo-agnostic.

General fish helpers available in the shell:

- `mkcd <dir>`: create a directory and enter it
- `take <path>`: create a nested path and enter it
- `cdf`: jump to the root of the current git repository
- `extract <archive>`: unpack common archive formats in place

Optional navigation tools wired into fish when installed:

- `fzf`: fuzzy history/file/directory selection via the upstream fish integration
- `zoxide`: smarter directory jumping with `z <query>` and interactive `zi`

Stow a single package (for example, EasyEffects audio presets):

```bash
stow easyeffects
```

## Task Tracking

This repo uses `bd` (Beads) as its local ticket tracker.

Common commands:

```bash
bd ready
bd list
bd create "Tune fish prompt" -p 2 -t task
bd show <id>
bd close <id> --reason "Done"
```

`bd` is part of the development workflow for this repo, not part of the shell UX. Use the normal `bd` commands directly instead of repo-specific shell shortcuts.

Restow a subset:

```bash
./scripts/stow.sh git terminal vscode
```

Remove symlinks created by Stow:

```bash
./scripts/unstow.sh
```

## Private local overlay

Tracked `.gitconfig` intentionally excludes name and email. Store machine- or identity-specific values in `~/.gitconfig.local`.

`gh auth login` recreates `~/.config/gh/hosts.yml`, which stays outside the repository because it contains auth state.

## Desktop overlay

The GNOME scripts are optional and target Ubuntu GNOME. They currently reproduce:

- Colloid dark compact rimless GTK/window theme
- Lightweight GTK overrides for cleaner titlebars and window buttons
- Theme and icon preferences
- Fonts and cursor theme
- Dock settings
- Enabled extensions
- GNOME Terminal transparency tweaks

## Architecture & decisions

See `docs/adr/` for the technical decisions behind this repo (e.g. why GNU Stow). Rules and context for AI agents live in `.github/copilot-instructions.md`.

## Notes

- `ghostty` is configured here, but installation is not automated because package availability varies by machine.
- VS Code tracked files only include stable user config, not caches or workspace state.

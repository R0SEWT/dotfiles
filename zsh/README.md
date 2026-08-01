# Zsh

This GNU Stow package manages `~/.zshrc` while keeping credentials outside the
public repository.

## Install

From the repository root:

```bash
stow --target="$HOME" zsh
```

## Private credentials

Copy the example once, add the real values, and restrict access:

```bash
mkdir -p ~/.config/zsh
cp ~/.config/zsh/secrets.zsh.example ~/.config/zsh/secrets.zsh
chmod 600 ~/.config/zsh/secrets.zsh
```

Update credentials only in `~/.config/zsh/secrets.zsh`. The real file is
ignored by Git and must never be added to this repository.

## Quick terminal assistant

The `fuck` function uses `codex exec` with `gpt-5.6-luna`, low reasoning, an
ephemeral session, and a read-only sandbox. Markdown output is rendered with
Python Rich when available, with `bat` and plain text as fallbacks.

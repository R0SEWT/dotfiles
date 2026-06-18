# 1. Use GNU Stow for Dotfiles

Date: 2026-03-29

## Status

Accepted

## Context

Managing dotfiles across different Linux installations can be tedious. Often, developers and system administrators write custom bash scripts or tools that recursively copy or symlink files into the correct locations in the home directory (`~/.config/` or `~/`).

However, custom scripts can:
- Fail silently or become hard to maintain over time.
- Lack a simple way to "uninstall" or remove symlinks effectively.
- Grow overly complex when adding new tools or variations of dotfiles.

## Decision

We will use **GNU Stow** to manage the symlinks for all dotfiles in this repository. 
Each tool or environment will have its own top-level directory (e.g., `easyeffects/`, `zsh/`, `nvim/`). 

We specifically forbid creating monolithic `install.sh` automatic scripts or complex tooling inside this repository.

## Consequences

- **Pros**:
  - Declarative-like management of symlinks.
  - Easy installation per module: `stow <package-name>`.
  - Easy removal: `stow -D <package-name>`.
  - Zero maintenance needed for an ad-hoc installation script.
- **Cons**:
  - Requires `stow` to be installed on the host system.
  - It expects manual commands (`stow`), requiring understanding from the user.
  - Directory structure within packages must properly mimic the target hierarchy (e.g. `nvil/.config/nvim/init.lua`).

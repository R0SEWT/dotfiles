# backup

One-way machine backup to an rclone remote (OneDrive, Google Drive, …) on a daily systemd
user timer. Each profile is one destination and lists exactly what goes:

- `REPOS`: git repos, uploaded as `git bundle --all` files → `<REMOTE>/repos/<name>.bundle`
- `ARTIFACTS`: directories outside git (datasets, weights), mirrored → `<REMOTE>/artifacts/<name>/`.
  Files deleted or replaced locally are moved to `<REMOTE>/_trash/<stamp>/`, not lost.

Nothing is backed up until a profile lists it.

## Rules

- **Never keep a git working tree in a two-way synced folder** (the OneDrive client, the
  `abraunegg/onedrive` daemon): lockfiles and atomic renames corrupt repos across machines.
  This module only pushes, when you tell it to.
- **GitHub stays the canonical remote for code.** Bundles are for private repos and unpushed
  work. A bundle does not include ignored files.
- **Personal and work never mix**: one profile and one remote each (e.g. `onedrive-upc:` and
  `onedrive-cip:`). Work data only goes to work storage.
- **Secrets never leave the machine.** `exclude.txt` drops `.env`, keys, `.credentials.json`,
  WhatsApp sessions and the like from every artifact directory. The script also refuses a source
  that is `~` or `/`, or that contains or sits inside `~/.ssh`, `~/.gnupg`, `~/.config/rclone`,
  `~/.config/gh`, the keyrings, the WhatsApp bridge session (`~/.local/share/wpp-mcp`), the Aula
  SSO profile (`~/.local/share/aula`) or the Claude/Codex logins.
- **Course material from the Aula is excluded** (`materials/`): it has its own private backup,
  `aula respaldo` in chrome-helper.
- `rclone mount --vfs-cache-mode full` is fine for browsing a backup, never as a git working tree.
- OneDrive limits: paths up to 400 characters, files up to 250 GB. Add `--tpslimit` to
  `RCLONE_FLAGS` only if the remote starts answering HTTP 429.

## Install

1. rclone from the official installer (apt ships 1.60):
   `sudo -v ; curl https://rclone.org/install.sh | sudo bash`
2. `rclone config` → new remote. With a work or school account, a login page that asks for
   admin approval means the tenant blocks rclone: pick another destination.
3. Create the target directories first, so Stow links the files instead of whole directories
   (otherwise `systemctl enable` would write into this repo), then stow:
   ```bash
   mkdir -p ~/.config/systemd/user ~/.config/machine-backup
   ./scripts/stow.sh backup
   ```
4. `cp examples/machine-backup.conf.example ~/.config/machine-backup/personal.conf` and edit it.
5. Try it: `machine-backup personal --dry-run`, then `machine-backup personal`.
6. Schedule it: `systemctl --user enable --now machine-backup@personal.timer`.
   Logs: `journalctl --user -u machine-backup@personal`.

## Restore

```bash
rclone copy <REMOTE>/repos/<name>.bundle .
git clone <name>.bundle <name>            # then: git remote set-url origin <url>
rclone copy <REMOTE>/artifacts/<name> <dir> # older versions: <REMOTE>/_trash/<stamp>/<name>/
```

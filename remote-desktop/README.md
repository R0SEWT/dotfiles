# remote-desktop

`rdesk <host>`: ver y controlar la sesión Wayland (Hyprland u otro compositor wlroots) de otra máquina del mesh ZeroTier.

```bash
rdesk fedora            # abre el escritorio de fedora en Remmina
rdesk -o DP-3 fedora    # captura otro monitor
rdesk -k es fedora      # teclado de wayvnc en español (ñ, tildes)
```

Ctrl-C en la terminal cierra el túnel.

## Cómo funciona

1. Por SSH arranca `wayvnc` dentro de la sesión Wayland del remoto, escuchando **solo en su `127.0.0.1:5900`**.
2. El mismo `ssh -L` lo trae a `127.0.0.1:5901` local (o el siguiente puerto libre).
3. Abre `vncviewer` (TigerVNC) si está instalado; si no, Remmina con un perfil temporal.
4. Al cerrar el túnel, el remoto recibe SIGHUP y `wayvnc` termina: no queda ningún puerto abierto.

Sin sudo, sin reglas de firewall y sin contraseña VNC: el acceso y el cifrado son los de SSH.

## Requisitos

- **Remoto:** `sshd` con tu llave, `wayvnc` (`sudo dnf install wayvnc`) y una sesión gráfica **iniciada** (con la pantalla bloqueada sirve: ves hyprlock y lo desbloqueas).
- **Local:** alias del host en `~/.ssh/config` y un visor: `remmina-plugin-vnc` (Ubuntu ya lo trae) o `tigervnc-viewer`.

## Limitaciones

- Comparte la sesión viva; no abre una sesión nueva. Si nadie inició sesión (tras un reinicio) no hay nada que mostrar; queda `ssh <host>`.
- Si el remoto se suspende (tapa cerrada) se pierde la conexión.
- Un monitor a la vez (`-o`); con varios, `wayvncctl output-cycle` en el remoto cambia de pantalla.
- `wayvnc` traduce keysyms con su propio layout (por defecto `us`): sin `-k es` no pasan ñ ni tildes.

## Instalar

```bash
stow remote-desktop
```

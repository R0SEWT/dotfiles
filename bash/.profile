# ~/.profile: executed by the command interpreter for login shells.

if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# NO reponer aqui `. "$HOME/.local/bin/env"`: el bloque de arriba ya pone
# ~/.local/bin en el PATH, y sourcear ese archivo dejo el equipo sin login el
# 2026-07-28 (ver ~/INFORME-CAUSA-RAIZ-login-2026-07-28.md). uv puede recrearlo.

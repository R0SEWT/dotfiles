# OPENSPEC:START
# OpenSpec shell completions — compinit handled by oh-my-zsh
fpath=("/home/rosewt-dell/.oh-my-zsh/custom/completions" $fpath)
# OPENSPEC:END

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="fox"

plugins=(
    git
    dnf
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Keep PATH stable even if helper scripts or lazy loaders add duplicate entries.
typeset -U path
path=(${path:#$HOME/.local/share/../bin})

# Display Pokemon-colorscripts
pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Aliases using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

alias simondice='sudo '
alias please='sudo '

# ssh desde kitty: el kitten copia el terminfo al remoto solo.
# Condicional para no romper ssh fuera de kitty (scripts, otra terminal).
[[ "$TERM" == "xterm-kitty" ]] && alias ssh='kitten ssh'

# Default Python workflow: uv + .venv. Conda stays opt-in for exceptional envs.
# >>> conda initialize (lazy) >>>
conda() {
    unfunction conda
    __conda_setup="$('/home/rosewt-dell/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/rosewt-dell/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/home/rosewt-dell/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/rosewt-dell/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    conda "$@"
}
# <<< conda initialize <<<

path=(
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.config/nvm/versions/node/v20.19.5/bin"
    "/usr/local/texlive/2025/bin/x86_64-linux"
    $path
)

# TeX Live 2025
export MANPATH=/usr/local/texlive/2025/texmf-dist/doc/man:$MANPATH
export INFOPATH=/usr/local/texlive/2025/texmf-dist/doc/info:$INFOPATH

# Lazy-load nvm itself; node/npm come from the pinned NVM PATH above.
export NVM_DIR="$HOME/.config/nvm"
_load_nvm() {
    unset -f nvm 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { _load_nvm; nvm "$@"; }
export PATH="$HOME/.local/bin:$PATH"

# Credenciales privadas locales (fuera de dotfiles).
_zsh_secrets_file="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/secrets.zsh"
if [[ -r "$_zsh_secrets_file" ]]; then
    source "$_zsh_secrets_file"
fi
unset _zsh_secrets_file

# infelix pipeline
source ~/.config/gt/sling-wrapper.zsh

# Pregunta rápida a Codex sin abrir una sesión interactiva.
#   fuck "como busco un archivo por cli"
#   ls -la | fuck "que significa la columna del medio"
# Sombrea al binario `thefuck` (sin configurar aquí); si lo necesitas: `command fuck`
fuck() {
    local prompt="$*" piped="" answer="" exit_code=0
    [[ -t 0 ]] || piped="$(cat)"
    if [[ -z "$prompt" && -z "$piped" ]]; then
        print -u2 'uso: fuck "tu pregunta"   |   comando | fuck "que hace esto"'
        return 1
    fi
    [[ -n "$piped" ]] && prompt+=$'\n\n--- salida del comando ---\n'"$piped"
    answer="$(codex exec \
        --model gpt-5.6-luna \
        -c 'model_reasoning_effort="low"' \
        -c 'approval_policy="never"' \
        --sandbox read-only \
        --skip-git-repo-check \
        --ephemeral \
        --color never \
        $'Responde en el idioma del usuario. Directo y breve, pensado para leerse en una terminal. Puedes ejecutar comandos de solo lectura cuando la respuesta dependa del estado de esta maquina. No modifiques archivos.\n\nSolicitud del usuario:\n'"$prompt" \
        </dev/null 2>/dev/null)" || exit_code=$?
    if (( exit_code != 0 )); then
        print -u2 "codex fallo (estado $exit_code); prueba: codex doctor"
        return "$exit_code"
    fi
    if python3 -c 'import rich.markdown' >/dev/null 2>&1; then
        print -r -- "$answer" | python3 -c \
            'import sys; from rich.console import Console; from rich.markdown import Markdown; Console().print(Markdown(sys.stdin.read()))'
    elif command -v bat >/dev/null 2>&1; then
        print -r -- "$answer" | bat --language=markdown --style=plain --paging=never --color=auto
    else
        print -r -- "$answer"
    fi
}

# NO sourcear ~/.local/bin/env: un archivo llamado `env` en un dir del PATH sombrea
# /usr/bin/env, y cualquier intento de arreglar eso con `exec` mata el shell de login
# al sourcearlo. Incidente 2026-07-28, ver ~/INFORME-CAUSA-RAIZ-login-2026-07-28.md
if [ -d "$HOME/.local/bin" ]; then
    case ":${PATH}:" in
        *:"$HOME/.local/bin":*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

if [ -x "$HOME/miniconda3/bin/conda" ]; then
    __conda_setup="$("$HOME/miniconda3/bin/conda" shell.zsh hook 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
    unset __conda_setup
fi

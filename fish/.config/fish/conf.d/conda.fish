if test -f "$HOME/miniconda3/bin/conda"
    eval "$HOME/miniconda3/bin/conda" "shell.fish" "hook" $argv | source
else if test -f "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
    . "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
else if test -d "$HOME/miniconda3/bin"
    set -x PATH "$HOME/miniconda3/bin" $PATH
end

if test -f "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
    . "$HOME/miniconda3/etc/fish/conf.d/conda.fish"
else if test -d "$HOME/miniconda3/bin"
    set -x PATH "$HOME/miniconda3/bin" $PATH
end

# Keep startup cheap by not auto-activating `base` on every new shell.
# Opt in explicitly with: `set -Ux CONDA_AUTO_ACTIVATE_BASE 1`
if set -q CONDA_AUTO_ACTIVATE_BASE
    if string match -qir '^(1|true|yes)$' -- "$CONDA_AUTO_ACTIVATE_BASE"
        conda activate base >/dev/null 2>/dev/null
    end
end

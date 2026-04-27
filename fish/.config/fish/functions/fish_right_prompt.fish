function fish_right_prompt
    set -l normal (set_color normal)
    set -l subtle (set_color brblack)
    set -l env_color (set_color yellow)
    set -l parts
    set -l clock (date +%H:%M)

    set parts $parts $clock

    if set -q CONDA_DEFAULT_ENV
        if test "$CONDA_DEFAULT_ENV" != base
            set parts $parts (string join '' $env_color $CONDA_DEFAULT_ENV $normal)
        end
    end

    if set -q CMD_DURATION
        if test "$CMD_DURATION" -ge 3000
            set -l seconds (math --scale 1 "$CMD_DURATION / 1000")
            set parts $parts "$seconds"'s'
        end
    end

    if test (count $parts) -gt 0
        printf '%s%s%s' $subtle (string join '  ' $parts) $normal
    end
end

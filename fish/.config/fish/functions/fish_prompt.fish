function fish_prompt
    set -l last_status $status
    set -l accent_color (set_color brblack)
    set -l path_color (set_color --bold blue)
    set -l git_color (set_color --bold magenta)
    set -l status_color (set_color red)
    set -l prompt_ok_color (set_color cyan)
    set -l prompt_error_color (set_color --bold red)
    set -l normal (set_color normal)
    set -l git_ref
    set -l prompt_symbol '>'

    set git_ref (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
    if test -z "$git_ref"
        set git_ref (command git rev-parse --short HEAD 2>/dev/null)
    end

    if functions -q fish_is_root_user
        and fish_is_root_user
        set prompt_symbol '#'
    end

    printf '%s╭─%s ' $accent_color $normal
    printf '%s%s%s' $path_color (prompt_pwd) $normal

    if test -n "$git_ref"
        printf ' %s·%s %s%s%s' $accent_color $normal $git_color $git_ref $normal
    end

    if test $last_status -ne 0
        printf ' %s[%s]%s' $status_color $last_status $normal
        printf '\n%s╰─%s %s%s%s ' $accent_color $normal $prompt_error_color $prompt_symbol $normal
    else
        printf '\n%s╰─%s %s%s%s ' $accent_color $normal $prompt_ok_color $prompt_symbol $normal
    end
end

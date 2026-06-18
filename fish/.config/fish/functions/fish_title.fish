function fish_title
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)
    set -l cwd (prompt_pwd)

    if test -n "$repo_root"
        set -l repo_name (basename "$repo_root")
        printf '%s :: %s' $repo_name $cwd
    else
        printf '%s' $cwd
    end
end

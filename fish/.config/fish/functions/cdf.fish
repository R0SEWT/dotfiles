function cdf --description 'Jump to the root of the current git repository'
    set -l repo_root (command git rev-parse --show-toplevel 2>/dev/null)

    if test -z "$repo_root"
        echo "cdf: not inside a git repository" >&2
        return 1
    end

    cd "$repo_root"
end

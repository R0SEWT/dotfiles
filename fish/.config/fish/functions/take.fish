function take --description 'Create a path and enter the deepest directory'
    if test (count $argv) -eq 0
        echo "usage: take <path>" >&2
        return 1
    end

    mkdir -p -- $argv[1]
    and cd -- $argv[1]
end

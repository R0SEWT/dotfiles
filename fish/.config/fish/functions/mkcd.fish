function mkcd --description 'Create a directory and enter it'
    if test (count $argv) -eq 0
        echo "usage: mkcd <directory>" >&2
        return 1
    end

    mkdir -p -- $argv[1]
    and cd -- $argv[1]
end

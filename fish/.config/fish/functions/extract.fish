function extract --description 'Extract a common archive format into the current directory'
    if test (count $argv) -eq 0
        echo "usage: extract <archive>" >&2
        return 1
    end

    set -l archive $argv[1]

    if not test -f "$archive"
        echo "extract: file not found: $archive" >&2
        return 1
    end

    switch $archive
        case '*.tar.gz' '*.tgz'
            tar -xzf "$archive"
        case '*.tar.bz2' '*.tbz2'
            tar -xjf "$archive"
        case '*.tar.xz' '*.txz'
            tar -xJf "$archive"
        case '*.tar'
            tar -xf "$archive"
        case '*.zip'
            unzip "$archive"
        case '*.gz'
            gunzip "$archive"
        case '*.bz2'
            bunzip2 "$archive"
        case '*.xz'
            unxz "$archive"
        case '*'
            echo "extract: unsupported archive format: $archive" >&2
            return 1
    end
end

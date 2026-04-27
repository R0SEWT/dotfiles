if command -q fzf
    if fzf --help 2>&1 | string match -qr -- '--fish'
        fzf --fish | source
    else if functions -q fzf_key_bindings
        fzf_key_bindings
    else if test -f /usr/share/doc/fzf/examples/key-bindings.fish
        source /usr/share/doc/fzf/examples/key-bindings.fish
        if functions -q fzf_key_bindings
            fzf_key_bindings
        end
    end
end

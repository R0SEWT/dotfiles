if status is-interactive
    if command -q fzf
        if not functions -q fzf_key_bindings
            for file in \
                /usr/share/fish/vendor_functions.d/fzf_key_bindings.fish \
                /usr/share/doc/fzf/examples/key-bindings.fish
                if test -f $file
                    source $file
                    break
                end
            end
        end

        if functions -q fzf_key_bindings
            fzf_key_bindings
        end
    end
end

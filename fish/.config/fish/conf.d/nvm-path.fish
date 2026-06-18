set -l nvm_versions_dir "$HOME/.nvm/versions/node"

if test -d "$nvm_versions_dir"
    set -l node_dir

    if test -f "$HOME/.nvm/alias/default"
        read -l default_alias < "$HOME/.nvm/alias/default"
        set default_alias (string trim -- "$default_alias")

        if test -n "$default_alias"
            string match -q 'v*' -- "$default_alias"; or set default_alias "v$default_alias"
            for candidate in "$nvm_versions_dir"/$default_alias*
                if test -d "$candidate"
                    set node_dir "$candidate"
                    break
                end
            end
        end
    end

    if test -z "$node_dir"
        set -l candidates "$nvm_versions_dir"/v*/
        if test (count $candidates) -eq 1
            set node_dir (string trim -r -c / -- "$candidates[1]")
        end
    end

    if test -n "$node_dir"
        set -l node_bin "$node_dir/bin"
        if test -d "$node_bin"
            fish_add_path --move --path "$node_bin"
        end
    end
end

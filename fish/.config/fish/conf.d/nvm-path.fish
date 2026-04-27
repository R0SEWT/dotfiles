set -l nvm_versions_dir "$HOME/.nvm/versions/node"

if test -d "$nvm_versions_dir"
    set -l latest_node_dir (find "$nvm_versions_dir" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n 1)
    if test -n "$latest_node_dir"
        set -l latest_node_bin "$latest_node_dir/bin"
        if test -d "$latest_node_bin"
            fish_add_path --move --path "$latest_node_bin"
        end
    end
end

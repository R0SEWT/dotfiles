set -g fish_greeting

set -g fish_color_autosuggestion 555 brblack
set -g fish_color_command brcyan
set -g fish_color_cwd blue --bold
set -g fish_color_error red --bold
set -g fish_color_operator magenta
set -g fish_color_param normal
set -g fish_color_quote bryellow
set -g fish_color_search_match --background=blue
set -g fish_color_selection --background=brblack
set -g fish_pager_color_completion cyan
set -g fish_pager_color_description yellow
set -g fish_pager_color_prefix cyan --bold
set -g fish_pager_color_progress brblack

# Load the managed prompt explicitly because the functions directory is
# symlinked by Stow.
source "$HOME/.config/fish/functions/fish_prompt.fish"
source "$HOME/.config/fish/functions/fish_right_prompt.fish"

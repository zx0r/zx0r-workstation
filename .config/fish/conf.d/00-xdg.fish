# ---
# schema: "mdd-node-v1"
# id: "conf.d/00-xdg.fish"
# title: "XDG Base Directory Specification"
# layer: "Foundation (00-09)"
# responsibility: "Establishes standard XDG directory layout and bootstraps workstation directories"
# dependencies: []
# backlinks: ["config.fish", "conf.d/01-path.fish", "conf.d/01-variables.fish"]
# created_at: "2026-06-24"
# updated_at: "2026-06-25"
# last_commit: "853273b8893d56d11bcf030b42de63bfa22f1837"
# tags: ["xdg", "directory", "bootstrap"]
# ---

# 1. XDG Base Directories (Performance Optimized / Fallbacks)
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME "$HOME/.config"
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME "$HOME/.cache"
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME "$HOME/.local/share"
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME "$HOME/.local/state"
set -q XDG_RUNTIME_DIR; or set -gx XDG_RUNTIME_DIR "$TMPDIR"

# 2. XDG User Directories
set -gx XDG_DESKTOP_DIR "$HOME/Desktop"
set -gx XDG_DOCUMENTS_DIR "$HOME/Documents"
set -gx XDG_DOWNLOADS_DIR "$HOME/Downloads"
set -gx XDG_PICTURES_DIR "$HOME/Pictures"
set -gx XDG_VIDEOS_DIR "$HOME/Movies"
set -gx XDG_MUSIC_DIR "$HOME/Music"
set -gx XDG_PUBLICSHARE_DIR "$HOME/Public"
set -gx XDG_SCREENSHOTS_DIR "$XDG_PICTURES_DIR/Screenshots"

# 3. Workstation Directory Layout Taxonomy (Workstation as Code / WaC)
set -gx XDG_PROJECTS_DIR "$HOME/x/dev"
set -gx XDG_DOTFILES_DIR "$HOME/x/dots"
set -gx XDG_BIN_DIR "$HOME/.local/bin"
set -gx XDG_BACKUP_DIR "$HOME/.config/fish/backups"

# 4. Directory Bootstrap (Ensures layout directories exist with secure permissions)
set -l xdg_directories_to_bootstrap $XDG_SCREENSHOTS_DIR $XDG_PROJECTS_DIR $XDG_DOTFILES_DIR $XDG_BIN_DIR
for target_directory_path in $xdg_directories_to_bootstrap
    if not test -d "$target_directory_path"
        mkdir -p -m 700 "$target_directory_path"
    end
end


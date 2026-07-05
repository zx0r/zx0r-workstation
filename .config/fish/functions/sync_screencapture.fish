# ---
# schema: "mdd-node-v1"
# id: "functions/sync_screencapture.fish"
# title: "macOS Screenshot Location Synchronizer"
# layer: "Functions"
# responsibility: "Synchronizes the system screenshot storage location to the designated XDG_SCREENSHOTS_DIR and restarts SystemUIServer"
# dependencies: ["defaults", "killall", "realpath"]
# backlinks: []
# created_at: "2026-06-25"
# updated_at: "2026-06-25"
# last_commit: ""
# tags: ["macos", "system", "utility"]
# ---

function sync_screencapture --description "Synchronize macOS screenshot directory to designated XDG Screenshots folder"
    if not set -q XDG_SCREENSHOTS_DIR
        echo "Error: XDG_SCREENSHOTS_DIR is not defined"
        return 1
    end

    if not test -d "$XDG_SCREENSHOTS_DIR"
        mkdir -p -m 700 "$XDG_SCREENSHOTS_DIR"
    end

    set -l current_loc (defaults read com.apple.screencapture location 2>/dev/null)
    set -l target_loc (realpath "$XDG_SCREENSHOTS_DIR")

    if test "$current_loc" != "$target_loc"
        echo "Updating macOS screenshot location to: $target_loc"
        defaults write com.apple.screencapture location "$target_loc"
        killall SystemUIServer 2>/dev/null
        echo "SystemUIServer restarted successfully."
    else
        echo "macOS screenshot location is already synchronized to: $target_loc"
    end
end

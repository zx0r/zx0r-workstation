# ---
# schema: "mdd-node-v1"
# id: "functions/nvim.fish"
# title: "Nvim"
# layer: "Functions"
# responsibility: "Wrapper for profile-aware nvimx routing"
# dependencies: []
# backlinks: []
# created_at: "2026-06-24"
# updated_at: "2026-06-25"
# last_commit: "f4adbd9652c78a01f562b7194602f3fa10eeea80"
# tags: []
# ---

function nvim --wraps nvim --description "Wrapper for profile-aware nvimx routing"
    # Route plain `nvim` calls through nvimx (profile-aware)
    # If NVIM_APPNAME is already set, call the real nvim to avoid recursion
    if test -z "$NVIM_APPNAME"; and type -q nvimx
        # If first argument looks like a flag, call real nvim (e.g. --version)
        if test (count $argv) -gt 0; and string match -qr '^-' -- $argv[1]
            command nvim $argv
        else
            nvimx $argv
        end
    else
        command nvim $argv
    end
end

# ---
# schema: "mdd-node-v1"
# id: "conf.d/10-runtimes.fish"
# title: "Self-Healing Runtime Cache Engine"
# layer: "Infrastructure (10-19)"
# responsibility: "Manages compiled static initializers for Mise, Starship, Zoxide, Atuin, and FZF with parallel invalidation and native UUID generation"
# dependencies: ["conf.d/01-variables.fish"]
# backlinks: ["config.fish"]
# created_at: "2026-06-24"
# updated_at: "2026-07-12"
# last_commit: "pending"
# tags: ["cache", "runtimes", "performance", "mise", "shims"]
# ---

# Defensive check: These tools are only relevant for interactive shell usage
status is-interactive; or return

# 1. Establish cache namespace
set -l static_cache_directory_path "$XDG_CACHE_HOME/fish/static_init"
test -d "$static_cache_directory_path"; or mkdir -p "$static_cache_directory_path"

set -l cache_pids

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. Check & Spawn Cache Generation
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# --- Mise (Polyglot Runtime Engine) ---
# ARCHITECTURAL DESIGN: Sourcing 'mise activate' is intentionally bypassed to satisfy
# the Zero-Fork SLA (<25ms) and maintain shims (~/.local/share/mise/shims) as the single
# source of truth in PATH. A static wrapper function handles shell-local commands (deactivate/shell/sh)
# at functions/mise.fish. All runtime version lookups are dynamically processed by shims.

# --- Starship (Prompt Engine) ---
set -l should_regenerate_starship_cache 0
set -l starship_binary_path (type -p starship)

if test -n "$starship_binary_path"
    if not test -f "$static_cache_directory_path/starship.fish"
        set should_regenerate_starship_cache 1
    else
        # Invalidate cache if config or the binary itself is newer than the cache file
        if set -q STARSHIP_CONFIG; and test -f "$STARSHIP_CONFIG"; and test "$STARSHIP_CONFIG" -nt "$static_cache_directory_path/starship.fish"
            set should_regenerate_starship_cache 1
        else if test "$starship_binary_path" -nt "$static_cache_directory_path/starship.fish"
            set should_regenerate_starship_cache 1
        end
    end
end

if test $should_regenerate_starship_cache -eq 1
    starship init fish --print-full-init >"$static_cache_directory_path/starship.fish" &
    set -a cache_pids $last_pid
end

# --- Zoxide (Fuzzy Navigation Engine) ---
set -l should_regenerate_zoxide_cache 0
set -l zoxide_binary_path (type -p zoxide)

if test -n "$zoxide_binary_path"
    if not test -f "$static_cache_directory_path/zoxide.fish"
        set should_regenerate_zoxide_cache 1
    else if test "$zoxide_binary_path" -nt "$static_cache_directory_path/zoxide.fish"
        set should_regenerate_zoxide_cache 1
    end
end

if test $should_regenerate_zoxide_cache -eq 1
    zoxide init fish >"$static_cache_directory_path/zoxide.fish" &
    set -a cache_pids $last_pid
end

# --- Atuin (Fuzzy History Engine) ---
set -l should_regenerate_atuin_cache 0
set -l atuin_binary_path (type -p atuin)

if test -n "$atuin_binary_path"
    if not test -f "$static_cache_directory_path/atuin.fish"
        set should_regenerate_atuin_cache 1
    else if test "$atuin_binary_path" -nt "$static_cache_directory_path/atuin.fish"
        set should_regenerate_atuin_cache 1
    end
end

if test $should_regenerate_atuin_cache -eq 1
    atuin init fish >"$static_cache_directory_path/atuin.fish" &
    set -a cache_pids $last_pid
end

# --- FZF Key Bindings ---
set -l should_regenerate_fzf_cache 0
set -l fzf_binary_path (type -p fzf)

if test -n "$fzf_binary_path"
    if not test -f "$static_cache_directory_path/fzf.fish"
        set should_regenerate_fzf_cache 1
    else if test "$fzf_binary_path" -nt "$static_cache_directory_path/fzf.fish"
        set should_regenerate_fzf_cache 1
    end
end

if test $should_regenerate_fzf_cache -eq 1
    fzf --fish >"$static_cache_directory_path/fzf.fish" &
    set -a cache_pids $last_pid
end

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. Wait for Parallel Generations & Load Runtimes
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if set -q cache_pids[1]
    wait $cache_pids
    # Post-process atuin.fish if it was regenerated to bypass 'atuin uuid' spawn
    if test -f "$static_cache_directory_path/atuin.fish"
        set -l atuin_content (cat "$static_cache_directory_path/atuin.fish")
        set -l native_uuid_code 'printf "%04x%04x-%04x-%04x-%04x-%04x%04x%04x" (random 0 65535) (random 0 65535) (random 0 65535) (random 16384 20479) (random 32768 49151) (random 0 65535) (random 0 65535) (random 0 65535)'
        set -l patched_content (string replace 'atuin uuid' "$native_uuid_code" $atuin_content)
        printf "%s\n" $patched_content > "$static_cache_directory_path/atuin.fish"
    end
end




if test -f "$static_cache_directory_path/starship.fish"
    source "$static_cache_directory_path/starship.fish"
end

if test -f "$static_cache_directory_path/zoxide.fish"
    source "$static_cache_directory_path/zoxide.fish"
end
if test -f "$static_cache_directory_path/atuin.fish"
    source "$static_cache_directory_path/atuin.fish"
    # Ensure hotkey triggers history search cleanly
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
end

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Maintenance Utility
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function refresh_shell_cache --description "Clear static fish shell cache and reload"
    rm -rf "$XDG_CACHE_HOME/fish/static_init"
    exec fish
end

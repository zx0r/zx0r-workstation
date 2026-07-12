# ---
# schema: "mdd-node-v1"
# id: "conf.d/25-fs-utils.fish"
# title: "Interactive File System Utilities"
# layer: "Commands (20-29)"
# responsibility: "Registers interactive search, navigation, permission, and Git helper functions at shell startup"
# dependencies: ["fzf", "fd", "rg", "git"]
# backlinks: ["config.fish"]
# created_at: "2026-06-25"
# updated_at: "2026-07-12"
# last_commit: "pending"
# tags: ["filesystem", "navigation", "fzf", "git"]
# ---

# Defensive check: All utility integrations are strictly relevant for interactive session ergonomics
status is-interactive; or return

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 1. Directory Navigation & Management
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function up --description "Move up N levels in the directory tree"
    set -l level 1
    if test (count $argv) -gt 0; and string match -qr '^[0-9]+$' -- $argv[1]
        set level $argv[1]
    end
    set -l path ""
    for i in (seq 1 $level)
        set path "$path../"
    end
    builtin cd "$path"
end

function mkcd --description "Create a directory path and immediately cd into it"
    if test -z "$argv[1]"
        echo "Usage: mkcd <directory>" >&2
        return 1
    end
    mkdir -p -- "$argv[1]"; and builtin cd "$argv[1]"
end

function mkcp --description "Create destination parent directory and copy files"
    if test (count $argv) -lt 2
        echo "Usage: mkcp <src...> <dest>" >&2
        return 1
    end
    set -l dest $argv[-1]
    set -l parent (dirname -- "$dest")
    if not test -d "$parent"
        mkdir -p -- "$parent"
    end
    cp -r $argv
end

function mkmv --description "Create destination parent directory and move files"
    if test (count $argv) -lt 2
        echo "Usage: mkmv <src...> <dest>" >&2
        return 1
    end
    set -l dest $argv[-1]
    set -l parent (dirname -- "$dest")
    if not test -d "$parent"
        mkdir -p -- "$parent"
    end
    mv $argv
end

function cdf --description "Change directory to macOS Finder's current target path"
    if not test (uname) = "Darwin"
        echo "Error: cdf is only supported on macOS." >&2
        return 1
    end
    set -l target_path (osascript -e 'tell application "Finder" to get POSIX path of (target of front window as alias)' 2>/dev/null)
    if test -n "$target_path"
        builtin cd "$target_path"
        echo "📂 Navigated to: $target_path"
    else
        echo "Error: Could not retrieve current Finder path." >&2
    end
end

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 2. File & Directory Permissions
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function chmodx --description "Make specified files executable"
    if test (count $argv) -lt 1
        echo "Usage: chmodx <files...>" >&2
        return 1
    end
    chmod +x -- $argv
end

function chownme --description "Change ownership of files/directories recursively to current user"
    if test (count $argv) -lt 1
        echo "Usage: chownme <paths...>" >&2
        return 1
    end
    sudo chown -R (whoami) -- $argv
end

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 3. Interactive File/Content Searches (FZF + fd + Ripgrep)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if command -sq fzf
    # Fuzzy find files in current folder using fzf preview
    function fzf_find --description "Fuzzy find files in current directory with preview"
        set -l file (fzf --preview 'bat --style=numbers --color=always --line-range=:100 {} 2>/dev/null || head -100 {}')
        if test -n "$file"
            echo "📄 Selected: $file"
        end
    end

    if command -sq fd
        # Find files using fd and fzf
        function fd_find --description "Search files with fd and fzf"
            set -l query "$argv"
            set -l file (fd --type f --hidden --exclude .git "$query" 2>/dev/null | fzf --preview 'bat --style=numbers --color=always --line-range=:100 {} 2>/dev/null || head -100 {}')
            if test -n "$file"
                echo "📄 Selected: $file"
            end
        end

        # Open selected files with $EDITOR
        function fo --description "Fuzzy find and open files in EDITOR"
            set -l file (fd --type f --hidden --exclude .git 2>/dev/null | fzf --preview 'bat --style=numbers --color=always --line-range=:100 {} 2>/dev/null || head -100 {}')
            if test -n "$file"
                set -l editor nvim
                if test -n "$EDITOR"
                    set editor $EDITOR
                end
                $editor "$file"
            end
        end
    end

    if command -sq rg
        # Search content with rg and fzf
        function rg_find --description "Search file contents with ripgrep and fzf"
            if test -z "$argv[1]"
                echo "Usage: rg_find <search_string>" >&2
                return 1
            end
            set -l file (rg --files-with-matches --hidden --smart-case --glob '!.git/*' -- "$argv[1]" 2>/dev/null | fzf --preview "rg --context 5 --color=always --pretty -- '$argv[1]' {}")
            if test -n "$file"
                echo "📄 Found in: $file"
            end
        end

        # Advanced ripgrep selector (Rg)
        function Rg --description "Interactive Ripgrep search with FZF"
            rg --column --line-number --no-heading --color=always --smart-case -- "$argv" 2>/dev/null | fzf --ansi \
                --delimiter : \
                --bind 'ctrl-e:become($EDITOR (echo {} | cut -d: -f1))' \
                --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} -- {1} 2>/dev/null || head -100 {1}' \
                --preview-window 'default:right:60%:~1:+{2}+3/2:border-left'
        end

        # Interactive TODO Comments Searcher
        function TODOS --description "Fuzzy list all TODO/FIXME comments in codebase"
            set -l rg_prefix "rg --column --hidden --line-number --no-heading --color=always --smart-case \
            '\\\\bFIXME\\\\b|\\\\bFIX\\\\b|\\\\bDISCOVER\\\\b|\\\\bNOTE\\\\b|\\\\bNOTES\\\\b|\\\\bINFO\\\\b|\\\\bOPTIMIZE\\\\b|\\\\bXXX\\\\b|\\\\bEXPLAIN\\\\b|\\\\bTODO\\\\b|\\\\bHACK\\\\b|\\\\bBUG\\\\b|\\\\bBUGS\\\\b'"

            set -l selected (fzf --bind "change:reload:$rg_prefix {q} || true" \
                --ansi --disabled \
                --delimiter : \
                --bind 'ctrl-e:execute($EDITOR (echo {} | cut -d: -f1) >/dev/tty </dev/tty)' \
                --preview 'bat --style=numbers,header,changes,snip --color=always --highlight-line {2} -- {1} 2>/dev/null || head -100 {1}' \
                --preview-window 'default:right:60%:~1:+{2}+3/2:border-left')

            if test -n "$selected"
                set -l parts (string split ":" -- "$selected")
                if test -n "$parts[1]"
                    set -l editor nvim
                    if test -n "$EDITOR"
                        set editor $EDITOR
                    end
                    $editor "+$parts[2]" -- "$parts[1]"
                end
            end
        end
    end
end

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 4. Standard Search Shorthands
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

function ff --description "Fast recursive search for files by name"
    if test -z "$argv[1]"
        echo "Usage: ff <pattern>" >&2
        return 1
    end
    find . -iname "*$argv[1]*" 2>/dev/null
end

function search --description "Search for text recursively in the current directory"
    if test -z "$argv[1]"
        echo "Usage: search <text>" >&2
        return 1
    end
    grep -rni -- "$argv[1]" . 2>/dev/null
end

function grep_string --description "Searches for clipboard string in the current directory"
    set -l search_string ""
    if test (uname) = "Darwin"
        set search_string (pbpaste)
    else if command -sq wl-paste
        set search_string (wl-paste)
    else if command -sq xclip
        set search_string (xclip -o -selection clipboard)
    end

    if test -n "$search_string"
        echo "🔎 Searching for: $search_string..."
        rg --hidden --no-ignore --glob '!.git/*' -- "$search_string" 2>/dev/null
    else
        echo "Error: Clipboard is empty." >&2
        return 1
    end
end

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 5. Fuzzy Git Integration Helpers
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if command -sq git; and command -sq fzf
    function gitf --description "Fuzzy find and select git-tracked files"
        set -l file (git ls-files | fzf --preview "bat --style=numbers --color=always --line-range=:100 {} 2>/dev/null || head -100 {}")
        if test -n "$file"
            echo "📄 Selected: $file"
        end
    end

    function gituf --description "Fuzzy find and select untracked git files"
        set -l file (git ls-files --others --exclude-standard | fzf --preview "bat --style=numbers --color=always --line-range=:100 {} 2>/dev/null || head -100 {}")
        if test -n "$file"
            echo "📄 Selected: $file"
        end
    end

    function gitlog --description "Fuzzy browser for git commit history"
        git log --oneline --graph --decorate --all | fzf --preview "git show --color=always {1}"
    end

    function gitbranch --description "Fuzzy selection and checkout of git branches"
        set -l branch (git branch --color=always | fzf --ansi | string trim | string replace -r '^\*\s+' '')
        if test -n "$branch"
            git checkout "$branch"
        end
    end
end

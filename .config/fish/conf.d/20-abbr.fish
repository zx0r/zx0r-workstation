# ---
# schema: "mdd-node-v1"
# id: "conf.d/20-abbr.fish"
# title: "Command Abbreviations Registry"
# layer: "Commands (20-29)"
# responsibility: "Registers user command abbreviations for quick workspace and tool navigation"
# dependencies: []
# backlinks: ["config.fish"]
# created_at: "2026-06-24"
# updated_at: "2026-06-25"
# last_commit: "853273b8893d56d11bcf030b42de63bfa22f1837"
# tags: ["abbreviations", "shortcuts", "productivity"]
# ---

# Defensive check: Abbreviations are only relevant for interactive shell usage
status is-interactive; or return

# 1. Package Management
abbr -a brewup "brew update && brew upgrade && brew cleanup && brew doctor" # Update Homebrew packages
abbr -a brew_clean "brew cleanup && brew autoremove" # Clean unused packages

# 2. System Maintenance & Controls
abbr -a flushdns "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder" # Clear DNS cache
abbr -a restart-ui "killall Dock; killall Finder; killall SystemUIServer" # Refresh UI

# 3. Core Editor & Terminal Shorthands
abbr -a c clear
abbr -a n nvim

# 4. File Management Utilities
abbr -a ln 'ln -sfv'
abbr -a cp 'cp -priv'
abbr -a mv 'mv -iv'
abbr -a rm 'rm -riv'
abbr -a mkdir 'mkdir -pv'
abbr -a mkdir-app 'mkdir -pv {src,public,tests}/{api,components,lib,utils}'

# 5. Fast Directory Navigation
abbr -a - 'cd -'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../../'
abbr -a .... 'cd ../../../'
abbr -a ..... 'cd ../../../../'

abbr -a cds "cd \$XDG_DATA_HOME"
abbr -a cfg "cd \$XDG_CONFIG_HOME"
abbr -a cdb "cd \$XDG_BIN_HOME"
abbr -a cdd "cd \$XDG_DOTFILES_DIR"
abbr -a cdp "cd \$XDG_PROJECTS_DIR"

abbr -a cdt "cd \$XDG_CONFIG_HOME/tmux"
abbr -a cdf "cd \$XDG_CONFIG_HOME/fish"
abbr -a cdn "cd \$XDG_CONFIG_HOME/nvim"

# 6. Editing & Sourcing Configs
abbr -a ea "nvim \$XDG_CONFIG_HOME/fish/conf.d/20-abbr.fish"
abbr -a et "nvim \$XDG_CONFIG_HOME/tmux/tmux.conf"
abbr -a ef "nvim \$XDG_CONFIG_HOME/fish/config.fish"

abbr -a sa "source \$HOME/.config/fish/conf.d/20-abbr.fish"
abbr -a sf "source \$HOME/.config/fish/config.fish"
abbr -a st "tmux source-file \$HOME/.config/tmux/tmux.conf"

# 7. File Permissions Shortcuts
abbr -a 000 'chmod -R 000' # No permissions for owner, group, or others
abbr -a 500 'chmod -R 500' # r-x------   Avoid Changing
abbr -a 600 'chmod -R 600' # rw-------   Read and write for owner only
abbr -a 644 'chmod -R 644' # rw-r--r--   Read/write for owner, read for group/others
abbr -a 660 'chmod -R 660' # rw-rw----   Read/write for owner and group
abbr -a 700 'chmod -R 700' # rwx------   Full access for owner only
abbr -a 755 'chmod -R 755' # rwxr-xr-x   Full access for owner, read/execute for others
abbr -a 777 'chmod -R 777' # rwxrwxrwx   Full access for everyone

abbr -a chmod- 'chmod -x'
abbr -a chmod+ 'chmod ug+x'

# 8. Dynamic eza / ls Setup (Avoids duplicate 'l' definition clashing)
if type -q eza
    alias l. "eza -a | egrep '^\.'"
    alias ls "eza -al --color=always --group-directories-first"
    alias la "eza -a --color=always --group-directories-first"
    alias ll "eza -abghilmu --icons=auto --color=always --group-directories-first"
    abbr -a lt "eza -aT --icons=auto --color=always --group-directories-first -snew"
    abbr -a lx "eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale --color=always --group-directories-first --icons=auto"
    abbr -a t "eza --tree --color=always --icons=auto"
    abbr -a t2 "eza --tree --level=2 --color=always --group-directories-first --icons=auto -snew"
    abbr -a t3 "eza --tree --level=3 --color=always --group-directories-first --icons=auto -snew"
    abbr -a t4 "eza --tree --level=4 --color=always --group-directories-first --icons=auto -snew"
    abbr -a l "clear && ll"
else
    abbr -a l "ls -lah"
    abbr -a la "ls -A"
    abbr -a ll "ls -lAFh"
    abbr -a lb "ls -lhSA"
    abbr -a lm "ls -tA -1"
end

# 9. Git Version Control Abbreviations
abbr -a g git
abbr -a gs "git status"
abbr -a ga "git add"
abbr -a gc "git commit"
abbr -a gp "git push"
abbr -a gl "git log --oneline -n 20"
abbr -a gd "git diff"
abbr -a gco "git checkout"
abbr -a gb "git branch"
abbr -a lg lazygit
abbr -a dot "git --git-dir=\$HOME/.git_bare_repo --work-tree=\$HOME"

# 10. Network & Port Inspection
abbr -a myip "curl ifconfig.me"
abbr -a ports "sudo lsof -iTCP -sTCP:LISTEN -P -n"

# 11. Tmux Session Orchestration
abbr -a ta "tmux attach -t"
abbr -a td "tmux attach -td"
abbr -a tn "tmux new-session -sd"
abbr -a ts "tmux switch-client -t"
abbr -a tl 'tmux list-sessions'
abbr -a tkw 'tmux kill-window -t'
abbr -a tks 'tmux kill-server'
abbr -a tkss 'tmux kill-session -t'
abbr -a tkall 'tmux list-sessions -F "#{session_name}" | xargs -I{} tmux kill-session -t {}'

# TMX (Ultimate Tmux Session Manager) abbreviations
abbr -a tx tmx
abbr -a txn 'tmx new'
abbr -a txd 'tmx daily'
abbr -a txs 'tmx switch'
abbr -a txk 'tmx kill'
abbr -a txl 'tmx ls'

# 12. Performance & Resource Auditing
abbr -a mem "vm_stat | awk '{print \$1, \$2}'"
abbr -a cpu "top -o cpu -stats pid,cpu,command"

# 13. Disk Usage & Performance Fallbacks (dust / ncdu support)
if type -q dust
    abbr -a du dust
    abbr -a dud "dust -d 1"
    abbr -a dush "dust -s"
else
    abbr -a du "du -ht"
    abbr -a dum "du --max-depth=1"
    abbr -a dus "du --summarize"
    abbr -a dud "du -d 1 -h"
    abbr -a dush "du -sh *"
end

if type -q ncdu
    abbr -a nd ncdu
end

# 14. Robust File Download Protocols (HTTP/3 and speed stats)
abbr -a cget "curl --proto '=https' --tlsv1.2 --http3 --compressed -fL#SO --write-out '\n⚡ %{speed_download} B/s • ⏱ %{time_total}s • 📦 %{size_download} bytes\n'"
abbr -a cpipe "curl --proto '=https' --tlsv1.2 --http3 --compressed -fsSL"
abbr -a curls 'curl -fOsSL --output-dir <some/dir/> {url}'
abbr -a curld 'curl -fsSL --output-dir <some/dir/filename> {url}'

abbr -a wget 'wget -O {url}'
abbr -a wget_output 'wget -qO- {url}'
abbr -a wgetd 'wget -P <some/dir/filename> {url}'

# 15. Zoxide Navigation (Wrapped for safety to prevent breaking standard cd)
if type -q zoxide
    abbr -a cd z
    abbr -a zz zi
end

# 16. Kitty Terminal Helpers
abbr -a kr "kitty @ load-config"
abbr -a ssh-kitty "kitty +kitten ssh user@host"

if type -q docker
    abbr -a d docker
    abbr -a dim 'docker images'
    abbr -a dp 'docker ps'
    abbr -a dpa 'docker ps -a'
    abbr -a dpq 'docker ps -q'
    abbr -a drmc 'docker rm -v (docker ps -qaf status=exited)'
    abbr -a drmca 'docker rm -fv (docker ps -qa)'
    abbr -a drmi 'docker rmi (docker images -qf dangling=true)'
    abbr -a drmig 'docker rmi (docker images -qf reference=)'
end

if type -q docker-compose
    abbr -a dc docker-compose
    abbr -a dcl 'docker-compose logs'
end

if type -q kubectl
    abbr -a kb kubectl
    abbr -a kbg 'kubectl get'
    abbr -a kbd 'kubectl describe'
    abbr -a kbl 'kubectl logs'
end

# 17. Miscellaneous
abbr -a valid_json 'python -m json.tool settings.json > /dev/null && echo "✅ Valid JSON"'

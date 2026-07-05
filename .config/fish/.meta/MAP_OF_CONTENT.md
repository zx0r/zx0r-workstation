# Map of Content: Shell Configuration Architecture

This document serves as the central index (Map of Content) and semantic dependency registry for the Fish shell workstation configuration. It maps files to atomic configuration nodes within the agentic graph database, enabling automated discovery, runtime analysis, and self-healing validation.

---

## I. Architectural Topology

The execution sequence is split into a **Decade-Spaced Modular Topology** (processed lexicographically by the Fish shell during startup within `conf.d/`) followed by the main orchestrator (`config.fish`).

```mermaid
graph TD

    subgraph L1["00–09 | Foundation Layer"]
        A00["00-xdg.fish<br/>XDG Bootstrap"]
        A01P["01-path.fish<br/>PATH Sanitizer"]
        A01V["01-variables.fish<br/>Env / Telemetry Opt-Out"]
        A02B["02-brew.fish<br/>Homebrew Static Map"]

        A00 --> A01P
        A00 --> A01V
        A01P --> A02B
    end

    subgraph L2["10–19 | Infrastructure Layer"]
        A10R["10-runtimes.fish<br/>Mise / Starship Cache"]
        A11S["11-ssh-gpg.fish<br/>SSH / GPG Socket Tmux"]

        A01V --> A10R
    end

    subgraph L3["20–29 | Commands Layer"]
        A20A["20-abbr.fish<br/>Command Shortcuts"]
    end

    subgraph L4["30–39 | UX & Styling"]
        A30U["30-ux.fish<br/>Prompt / Vi Cursor"]
    end

    subgraph L5["40–49 | Input Layer"]
        A40K["40-keymaps.fish<br/>Vi Keys & Widgets"]

        A30U --> A40K
    end

    subgraph L6["50–59 | Tooling Layer"]
        A50U["50-utils.fish<br/>Fzf / Bat / Tools"]
    end

    subgraph CFG["Main Entrypoint"]
        CF["config.fish<br/>Lifecycle Orchestrator"]
    end

    %% Layer execution order
    L1 --> L2
    L2 --> L3
    L3 --> L4
    L4 --> L5
    L5 --> L6
    L6 --> CFG
```

---

## II. Semantic Node Registry

Every file in this configuration contains a structured YAML-compliant comment block at the top representing metadata for programmatic ingestion.

| Node (File Path) | Title | Layer | Dependencies | Backlinks (Referrers) | Created | Updated | Tags |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | Main Configuration Entrypoint | Entrypoint / Orchestrator | `conf.d/*` | None | 2026-06-24 | 2026-07-05 | `entrypoint`, `lifecycle`, `bootstrap`, `orchestration` |
| [`conf.d/00-xdg.fish`](file:///Users/x0r/.config/fish/conf.d/00-xdg.fish) | XDG Base Directory Spec | Foundation (00-09) | None | [`config.fish`](file:///Users/x0r/.config/fish/config.fish), [`01-path.fish`](file:///Users/x0r/.config/fish/conf.d/01-path.fish), [`01-variables.fish`](file:///Users/x0r/.config/fish/conf.d/01-variables.fish) | 2026-06-24 | 2026-06-25 | `xdg`, `directory`, `bootstrap`, `wac` |
| [`conf.d/01-path.fish`](file:///Users/x0r/.config/fish/conf.d/01-path.fish) | Vectorized Native PATH Sanitization | Foundation (00-09) | [`00-xdg.fish`](file:///Users/x0r/.config/fish/conf.d/00-xdg.fish) | [`config.fish`](file:///Users/x0r/.config/fish/config.fish), [`02-brew.fish`](file:///Users/x0r/.config/fish/conf.d/02-brew.fish) | 2026-06-24 | 2026-06-25 | `path`, `sanitization`, `C++ builtins`, `performance` |
| [`conf.d/01-variables.fish`](file:///Users/x0r/.config/fish/conf.d/01-variables.fish) | Foundation Env Variables | Foundation (00-09) | [`00-xdg.fish`](file:///Users/x0r/.config/fish/conf.d/00-xdg.fish) | [`config.fish`](file:///Users/x0r/.config/fish/config.fish), [`10-runtimes.fish`](file:///Users/x0r/.config/fish/conf.d/10-runtimes.fish) | 2026-06-24 | 2026-06-25 | `variables`, `environment`, `telemetry`, `locale` |
| [`conf.d/02-brew.fish`](file:///Users/x0r/.config/fish/conf.d/02-brew.fish) | Homebrew Environment Mapping | Foundation (00-09) | [`01-path.fish`](file:///Users/x0r/.config/fish/conf.d/01-path.fish) | [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | 2026-06-24 | 2026-06-25 | `homebrew`, `environment`, `performance`, `zero-fork` |
| [`conf.d/10-runtimes.fish`](file:///Users/x0r/.config/fish/conf.d/10-runtimes.fish) | Self-Healing Runtime Cache Engine | Infrastructure (10-19) | [`01-variables.fish`](file:///Users/x0r/.config/fish/conf.d/01-variables.fish) | [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | 2026-06-24 | 2026-07-05 | `cache`, `runtimes`, `starship`, `mise`, `performance` |
| [`conf.d/11-ssh-gpg.fish`](file:///Users/x0r/.config/fish/conf.d/11-ssh-gpg.fish) | SSH & GPG Crypto Infrastructure | Infrastructure (10-19) | None | [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | 2026-06-24 | 2026-06-29 | `ssh`, `gpg`, `agent`, `security`, `tmux` |
| [`conf.d/20-abbr.fish`](file:///Users/x0r/.config/fish/conf.d/20-abbr.fish) | Command Abbreviations Registry | Commands (20-29) | None | [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | 2026-06-24 | 2026-06-25 | `abbreviations`, `shortcuts`, `productivity` |
| [`conf.d/30-ux.fish`](file:///Users/x0r/.config/fish/conf.d/30-ux.fish) | Shell Presentation & UX Layer | UX / UI (30-39) | None | [`config.fish`](file:///Users/x0r/.config/fish/config.fish), [`40-keymaps.fish`](file:///Users/x0r/.config/fish/conf.d/40-keymaps.fish) | 2026-06-24 | 2026-06-25 | `ux`, `cursor`, `prompt`, `history` |
| [`themes/colorscheme.fish`](file:///Users/x0r/.config/fish/themes/colorscheme.fish) | Cyberpunk Neon Color Palette | UX / UI (30-39) | None | [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | 2026-06-24 | 2026-06-25 | `colorscheme`, `theme`, `cyberpunk`, `palette` |
| [`conf.d/40-keymaps.fish`](file:///Users/x0r/.config/fish/conf.d/40-keymaps.fish) | Keyboard Mappings & Vi Bindings | Input & Mappings (40-49) | [`30-ux.fish`](file:///Users/x0r/.config/fish/conf.d/30-ux.fish) | [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | 2026-06-24 | 2026-06-25 | `keymaps`, `bindings`, `vi-mode`, `widgets` |
| [`conf.d/50-utils.fish`](file:///Users/x0r/.config/fish/conf.d/50-utils.fish) | Third-Party Tool Integrations | Tooling (50-59) | None | [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | 2026-06-24 | 2026-06-29 | `tooling`, `fzf`, `bat`, `fd`, `tree-sitter` |
| [`conf.d/50-fzf.fish`](file:///Users/x0r/.config/fish/conf.d/50-fzf.fish) | Fzf Fuzzy Finder Configuration | Tooling (50-59) | None | [`config.fish`](file:///Users/x0r/.config/fish/config.fish) | 2026-06-26 | 2026-06-29 | `fzf`, `tooling`, `fuzzy-finder` |
| [`.meta/log/changelog.md`](file:///Users/x0r/.config/fish/.meta/log/changelog.md) | MDD Chronology & Changelog | Meta / Logging | None | [`.agents/AGENTS.md`](file:///Users/x0r/.config/fish/.agents/AGENTS.md) | 2026-06-25 | 2026-06-26 | `changelog`, `history`, `mdd`, `audit` |

---

## III. Modular Layers Breakdown

### 1. Foundation Layer (00-09)
*   **Purpose:** Bootstraps critical variables that define execution environments for all child shells.
*   **Rules:**
    *   No external binary executions (zero `fork()`/`exec()`). Only native shell script syntax and builtins.
    *   Defensive validation of environment state.
    *   Telemetry Opt-Out configuration ensures absolute local isolation before runtimes are queried or initialized.

### 2. Infrastructure Layer (10-19)
*   **Purpose:** Manages compiler wrappers, environment runtime engines, cache stores, and session-long daemon sockets (SSH/GPG).
*   **Rules:**
    *   Cached configurations are invalidated if binaries are modified or updated (checksum-based verification against cached outputs).
    *   Agent forwarding must adapt dynamically to TMUX session environment changes.

### 3. Commands Layer (20-29)
*   **Purpose:** Accelerates developer throughput via high-density shortcuts.
*   **Rules:**
    *   Uses Fish's native `abbr` mechanism which evaluates lazily and avoids runtime overhead.

### 4. UX & Styling Layer (30-39)
*   **Purpose:** Configures visual presentation, colors, cursors, and interactive prompts.
*   **Rules:**
    *   Avoids heavy external scripts. Uses fast asynchronously loaded settings.

### 5. Input & Mappings Layer (40-49)
*   **Purpose:** Keybinding configurations for fast line editing (Vi-mode) and multi-select fuzzy-finding.
*   **Rules:**
    *   Leverages FZF keybindings with performant fallback hooks.

### 6. Tooling Layer (50-59)
*   **Purpose:** Fine-tunes integrations with third-party tools such as `bat`, `fd`, and `nvim`.
*   **Rules:**
    *   Variables are conditionally declared if binaries exist.

---

## IV. Graph Database Ingestion Protocol

For an AI Agent to parse and register this codebase as an atomic graph database:

1.  **Node Identification:**
    Each `.fish` file containing `# ---` to `# ---` represents a `DocumentNode` (or `AtomicNote`).
2.  **Metadata Extraction:**
    A YAML parser must read the comment block:
    ```regex
    ^#\s*---\n([\s\S]*?)^#\s*---
    ```
    Strip `# ` from each line to form standard YAML:
    ```yaml
    title: Node Title
    module: relative/path/to/file.fish
    layer: Layer Name
    responsibility: Description of purpose
    dependencies: [list, of, dependencies]
    backlinks: [list, of, backlink, referrers]
    created_at: YYYY-MM-DD
    updated_at: YYYY-MM-DD
    tags: [tag1, tag2]
    ```
3.  **Edge Creation:**
    *   Create directional dependency edges `(SourceNode)-[:DEPENDS_ON]->(TargetNode)` based on the `dependencies` array.
    *   Create directional referrer edges `(TargetNode)-[:REFERRED_BY]->(SourceNode)` based on the `backlinks` array.
4.  **Implicit Associations:**
    *   Create tag nodes and associate documents using `(DocumentNode)-[:HAS_TAG]->(TagNode)`.

---

## V. Startup Performance SLA

All optimizations (caching, lazy-loading, bypassing Homebrew dynamic configuration) are designed to satisfy:
*   **Cold Boot Time:** $< 25\text{ms}$ on macOS (Apple Silicon architecture).
*   **Interactive Boot Time:** $< 50\text{ms}$.
*   **Interactive Shell Greets:** Bypassed dynamically or cached for instant render.

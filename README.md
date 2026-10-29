# Dendritic NixOS Workstations: Castor & Hyde

An atomic, dendritic NixOS configuration managing two specialized workstations (`castor` and `hyde`), scrollable tiling with Niri, Noctalia dynamic theme authority, layerless Programmer QWERTY hardware input interception, an editor-multiplexer workflow, and a 5-shell parity layer.

---

## Quick Start

~~~sh
# On workstation Hyde (AMD Compute Workstation)
sudo nixos-rebuild switch --flake /etc/nixos#hyde

# On workstation Castor (Intel Mobile Workstation)
sudo nixos-rebuild switch --flake /etc/nixos#castor
~~~

Checkout path expected at `/etc/nixos`.

---

## Topology & Workstation Roles

| Host | Primary User | Graphics & Compute Stack | Storage, Kernel & Memory Invariants | Workstation Role |
| :--- | :--- | :--- | :--- | :--- |
| **hyde** | `jekyll` | AMD Radeon (`amdgpu`) + declarative OpenCL (`hardware.amdgpu.opencl.enable`) + pre-built HIP Cycles compute (`pkgs.pkgsRocm.blender`) | Kingston NV2 APST fix (`nvme_core.default_ps_max_latency_us=0`), `pcie_aspm=off`, deterministic device timeout (`systemd.default_device_timeout_sec=30`), root ext4 flags (`noatime,commit=60`), pure ZRAM swappiness (`vm.swappiness = 180`) | Main workstation: 3D Blender Cycles rendering, compute & dev |
| **castor** | `pollux` | Intel Iris Xe (`intel-media-driver` / `iHD`) | Framebuffer compression (`i915.enable_fbc=1`), aggressive zram swappiness (`180`), root ext4 flags (`noatime,commit=60`), thermald | Secondary workstation: Lightweight, mobile efficiency & media |

---

## Five-Shell Parity Layer (Bash, Zsh, Fish, Nushell, Xonsh)

A unified single-source-of-truth declared at `modules/shared/core/default.nix` compiles aliases and tool hooks into all 5 shells identically:

| Canonical Alias | Command Target | Description |
| :--- | :--- | :--- |
| `grep` | `rg` | Ripgrep fast AST-aware pattern search |
| `find` | `fd` | Fast, colorized directory hierarchy traversal |
| `sed` | `sd` | Intuitive, fast regex find & replace |
| `du` | `dust` | Visual terminal disk usage analyzer |
| `cat` | `bat` | Syntax-highlighted pager with git integration |
| `f` / `tv` | `television` | Fast fuzzy matcher and channel inspector TUI |
| `rebuild` | `git -C /etc/nixos add -A && sudo nixos-rebuild switch ...` | Stage changes and rebuild active workstation |
| `rebuildh` | `git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos#hyde` | Explicit build for compute host `hyde` |
| `rebuildc` | `git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos#castor` | Explicit build for mobile host `castor` |
| `cfb nix` | `cfb /etc/nixos` | Copies tree topology + config contents to Wayland clipboard |
| `cfb cfg` | `cfb ~/.config` | Copies clean `~/.config` snapshot to Wayland clipboard |
| `v` / `vi` / `vim` | `nvim` | Opens modal editor (Neovim via Nixvim) |
| `bottom` / `btm` | `btop` | System activity monitor with Catppuccin transparent background |
| `lh` | `learnharness` | Socratic agent harness for mastering complex technical domains |
| `y` | `yazi` | Fast asynchronous terminal file manager |
| `lg` | `lazygit` | Terminal Git staging and branch manager |

Prompt initialization across all shells points strictly to `/etc/starship.toml` with native `zoxide`, `direnv`, and `mise` evaluations. Shell history resolution via `Ctrl-R` is exclusively yielded to **Atuin** with transparent Catppuccin Mocha theming, while **FZF** retains fast file and directory navigation widgets.

---

## Developer Tooling & AI Coding Agent Harnesses

| Tool | Category | Runtime / Engine | Execution Purpose |
| :--- | :--- | :--- | :--- |
| `learnharness` | Learning Agent | TypeScript / Electron / Pi Subagents | Active conceptual learning with Socratic probing, dependency DAGs, and knowledge graphs |
| `herdr` | Agent Multiplexer | Native Rust / Ghostty VT | Multi-agent terminal runtime and session orchestrator |
| `agy` | Google Antigravity | Antigravity Core Engine | Terminal surface for Antigravity code reasoning and edit passes |
| `codex` | OpenAI Codex CLI | Node.js 22 LTS Isolated | Terminal-first coding agent loop, diff reviews, and MCP servers |
| `pi` | Agent Harness | Node.js 22 LTS Isolated | Minimal, extensible agent harness with branchable DAG sessions |
| `upmd` | Workflow Runner | Rust / Ratatui TUI | Executes Markdown codeblocks as dependency-aware pipelines |
| `endcord` | Discord TUI | Python 3 / Curses | Ultra-low-resource terminal Discord client |
| `quien` | Network Intelligence | Go / Ratatui TUI | Modern interactive WHOIS and domain intelligence visualizer |
| `lazyrsync` | Data Transfer | Rust / Rsync TUI | Interactive Rsync profile manager with live diff preview |
| `lazyssh` | Remote Access | Go / SSH TUI | Terminal fleet manager and configuration browser |
| `usbtree` | Hardware Diagnostics | Rust / Nusb | Live USB device tree and endpoint activity visualizer |
| `linecast` | Environment TUI | Python / Minitel UI | Terminal ephemeris: weather, radar, moon phases, and tides |
| `devenv` / `direnv` | Shell Isolation | Nix Flakes Native | Per-directory declarative toolchain loading |

---

## Primary Editor (Neovim / Nixvim)

Neovim is declaratively baked via `nixvim`:
* **Transparent Canvas**: Catppuccin Mocha theme with `transparent_background = true` matching Niri's dual-pass GPU blur.
* **Devenv & Direnv Integration**: Automatic in-editor environment sync via `direnv-vim`.
* **Code Formatting**: Format-on-save powered by `conform-nvim` with dedicated formatters (`nixfmt`, `shfmt`, `prettier`, `jq`) bundled into the wrapper and accessible on demand via `<Space> c f`.
* **Intelligence**: Native LSP (`nixd`, `bashls`, `marksman`, `taplo`, `yamlls`, `jsonls`, `gopls`, `rust-analyzer`), autocompletion (`cmp`), fuzzy pickers (`telescope`), diagnostics triage (`trouble`), and file tree (`neo-tree`).

---

## Typography & Subpixel DPI Engineering

| Target | Display Font | Terminal / Monospace Font | Target DPI (`XFT_DPI`) | True Pixel Metrics |
| :--- | :--- | :--- | :--- | :--- |
| **hyde (24" 1080p)** | Atkinson Hyperlegible | AtkynsonMono Nerd Font | `96` | 16px Foot (`size=16px`), 12pt Ghostty |
| **castor (15.6" 1080p)** | Atkinson Hyperlegible | AtkynsonMono Nerd Font | `141` | 16px Foot (`size=16px`), native density scaling |

---

## Keybinding Taxonomy

### Space Tree (Viewport Fill & Floating Layer)
* **`Mod + Space`**: Fill Screen (Maximize Column Width)
* **`Mod + Shift + Space`**: Fullscreen Window
* **`Mod + Ctrl + Space`**: Toggle Window Floating
* **`Mod + Alt + Space`**: Switch Focus Floating/Tiling

### Left Hand: Core Engines & Noctalia Panels
* **`Mod + F`**: Terminal: Foot Client (Fast Daemon) • **`Shift`**: Tmux Sessionizer • **`Ctrl`**: Ghostty
* **`Mod + D`**: Browser: LibreWolf • **`Shift`**: Brave Origin • **`Ctrl`**: Private Window
* **`Mod + S`**: Files: PCManFM • **`Shift`**: Floating PCManFM Dialog
* **`Mod + A`**: Chat: Ferdium • **`Shift`**: Niri Workspace Overview • **`Ctrl`**: Floating Ferdium
* **`Mod + G`**: Notes: Obsidian • **`Shift`**: Floating Obsidian Quick Note
* **`Mod + T`**: Snip: Area Screenshot to Clipboard • **`Shift`**: Fullscreen Screenshot
* **`Mod + E`**: Notices: Notification Center • **`Shift`**: Clear History
* **`Mod + X`**: Notices: Dismiss Active Notice
* **`Mod + V`**: Settings: Noctalia Settings GUI • **`Shift`**: Clipboard History Panel
* **`Mod + C`**: Control Center • **`Shift`**: Pavucontrol Mixer
* **`Mod + B`**: Bluetooth Panel • **`Shift`**: Bitwarden Desktop Client
* **`Mod + W`**: Wi-Fi Panel • **`Shift`**: Wallpaper Panel • **`Ctrl`**: Toggle Top Bar
* **`Mod + R`**: Launcher: Noctalia App Runner • **`Shift`**: Interactive Fuzzel Cheat Sheet
* **`Mod + Esc`**: Session Menu • **`Shift`**: Lock Screen • **`Ctrl`**: Turn Off Displays
* **`Mod + Q`**: Close Window • **`Shift`**: Kill Window

### Right Hand: Coalesced HJKL Navigation, Movement & Resizing
* **`Mod + H / L`**: Focus Column Left / Right
* **`Mod + Shift + H / L`**: Move Column Left / Right
* **`Mod + Ctrl + H / L`**: Shrink / Expand Column Width (`-5%` / `+5%`)
* **`Mod + J / K`**: Focus Workspace Down / Up
* **`Mod + Shift + J / K`**: Move Column to Workspace Down / Up
* **`Mod + U / I`**: Focus Window Down / Up (inside column stack)
* **`Mod + Shift + U / I`**: Move Window Down / Up (inside column stack)
* **`Mod + Ctrl + U / I`**: Shrink / Expand Window Height (`-5%` / `+5%`)
* **`Mod + M`**: Consume Window into Column from Left
* **`Mod + ,` (Comma)**: Consume Window into Column from Right
* **`Mod + .` (Period)**: Expel Window from Column
* **`Mod + 1..9`**: Focus Named Workspaces `"one"` through `"nine"`
* **`Mod + 0`**: Focus 10th Dynamic Workspace

# NixOS Workstations: Hyde & Castor

Declarative dual-host workstation configuration managed with NixOS Flakes, Niri, and Catppuccin Mocha.

---

## 1. Fleet Overview

| Host | Primary User | Role | Graphics & Compute | Primary Display | Profile |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **hyde** | `jekyll` | Compute & Production | AMD GPU, ROCm Cycles, OpenCL | DP-1 (1920x1080 @ 240Hz) | Desktop Workstation |
| **castor** | `pollux` | Mobile Efficiency | Intel Iris Xe (`iHD`), thermald, PPD | eDP-1 (Native @ 141 DPI) | Mobile Laptop |

---

## 2. Core Architecture

| Subsystem | Selection | Implementation Details |
| :--- | :--- | :--- |
| **Compositor** | **Niri** | Scrollable-tiling Wayland compositor. Layout: 4px radius, 2px borders, 8px gaps, GPU blur. |
| **Desktop Shell** | **Noctalia** | Top bar, notification center, control center, lockscreen widgets, DDC/CI brightness. |
| **Typography** | **Atkinson** | Atkinson Hyperlegible (UI sans-serif) and AtkynsonMono Nerd Font (fixed-width monospace). |
| **Theme Engine** | **Catppuccin Mocha** | Single-source palette with Mauve accent, 0.85 window opacity, dual-pass GPU blur. |
| **Editor** | **Helix** | Default editor (`hx`). Modal editing, LSP integration (`nixd`, `taplo`, etc.), system clipboard. |
| **Multiplexer** | **Zellij** | `zjstatus` WASM status bar, Tmux navigation layer (`Ctrl+Space`), session serialization. |
| **Interactive Shell** | **Fish** | Vi key bindings, Atuin history sync, Carapace completions, space-expanded abbreviations. |
| **Browsers** | **LibreWolf / Brave** | LibreWolf (Tridactyl native, Sidebery, custom CSS) with Brave Origin secondary fallback. |
| **Mesh Network** | **Tailscale** | MagicDNS node routing, strict deploy firewall (`tailscale0` port 22 only). |

---

## 3. Workflow & Operations

All management commands run directly in Fish:

~~~fish
# Inspect state and stage changes
gst                     # Check git status for untracked or sensitive files
ga                      # Stage changes in /etc/nixos
nh os build             # Build local generation closure without activating

# Local deployment
ntest                   # Activate temporary generation (reboot reverts)
nr                      # Switch permanently to new generation
nboot                   # Set next boot generation without activating

# Remote deployment (Hyde acts as build host)
nr castor               # Build on hyde, transfer and activate on castor
ntest castor            # Test generation remotely on castor
nboot castor            # Set next boot generation remotely on castor

# Noctalia GUI state synchronization
nsync                   # Merge runtime GUI tweaks into declarative base and rebuild

# LLM context generation
rnix                    # Pack /etc/nixos via repomix to clipboard
rcfg                    # Pack ~/.config via repomix to clipboard
~~~

---

## 4. Keybinding Matrix

Compositor modifier is `Mod` (`Super` / `Logo`).

### Space Tree: Viewport & Layout
| Keybind | Action |
| :--- | :--- |
| `Mod + Space` | Fill screen (maximize column width) |
| `Mod + Shift + Space` | Fullscreen window |
| `Mod + Ctrl + Space` | Toggle window floating |
| `Mod + Alt + Space` | Switch focus between floating and tiling layers |

### Left Hand: Applications & Panels
| Keybind | Action |
| :--- | :--- |
| `Mod + F` | Terminal: Foot client (Shift: Zellij workspace main, Ctrl: Session picker) |
| `Mod + D` | Browser: LibreWolf (Shift: Brave Origin, Ctrl: Private window) |
| `Mod + S` | File Manager: PCManFM |
| `Mod + A` | Messaging: Ferdium (Shift: Niri overview) |
| `Mod + G` | Knowledge Vault: Obsidian |
| `Mod + T` | Snip: Area screenshot to clipboard (Shift: Fullscreen) |
| `Mod + E` | Notices: Notification center (Shift: Clear history, `Mod + X`: Dismiss active) |
| `Mod + V` | Settings: Noctalia GUI (Shift: Clipboard manager panel) |
| `Mod + C` | Control Center: Quick toggles (Shift: Pavucontrol audio mixer) |
| `Mod + B` | Security: Bitwarden desktop (Shift: Noctalia vault panel, Ctrl: Bluetooth) |
| `Mod + W` | Wallpaper: Noctalia picker (Shift: Network panel, Ctrl: Toggle top bar) |
| `Mod + R` | Capture: OBS Studio (Shift: Noctalia OBS control panel) |
| `Mod + Z` | System: Toggle Lid Guard sleep inhibitor |
| `Mod + X` | System: Toggle Key Visualizer HUD overlay (Shift: Dismiss active notice) |
| `Mod + ;` | Launcher: Noctalia application runner |
| `Mod + /` | Cheatsheet: Keybind cheatsheet overlay |
| `Mod + Esc` | Session: Noctalia power menu (Shift: Lock screen, Ctrl: Turn off displays) |
| `Mod + Q` | Close focused window |

### Right Hand: Ribbon & Workspace Navigation
| Keybind | Action |
| :--- | :--- |
| `Mod + H / L` | Focus column left / right |
| `Mod + Shift + H / L` | Move column left / right |
| `Mod + Ctrl + H / L` | Resize column width (-5% / +5%) |
| `Mod + J / K` | Focus workspace down / up |
| `Mod + Shift + J / K` | Move column to workspace down / up |
| `Mod + U / I` | Focus window down / up inside column stack |
| `Mod + Shift + U / I` | Move window down / up inside column stack |
| `Mod + Ctrl + U / I` | Resize window height (-5% / +5%) |
| `Mod + M / ,` | Consume window into column from left / right |
| `Mod + .` | Expel window from column |
| `Mod + 1..9, 0` | Focus workspace 1 through 10 (Shift: Move column) |

---

## 5. Security & Invariant Rules

- **SSHD Hardening:** SSH daemon is exposed strictly on `tailscale0`. Passwords and keyboard-interactive auth are disabled. Root logins require dedicated Ed25519 deploy keys restricted by Tailscale CIDR (`100.64.0.0/10,fd7a:115c:a1e0::/48`).
- **Memory Subsystem:** Both machines operate swapless disk layouts with pure ZRAM. Kernel parameters require `vm.swappiness = 180`, `vm.watermark_scale_factor = 125`, and `vm.page-cluster = 0` to eliminate file cache eviction and I/O thrashing.
- **Compute Isolation:** ROCm, OpenCL, and compute-heavy suites reside strictly in `modules/hosts/hyde` and are never evaluated on `castor`.
- **Pure Flake Evaluation:** Runtime downloads (`curl | bash`, unpinned URLs, unhashed derivations) and imperative runtime installers are prohibited by NixOS module assertions.


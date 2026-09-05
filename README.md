
# 🌌 Castor — Dendritic NixOS Flake

A production-grade, modular NixOS workstation engineered with **`flake-parts`**, **`import-tree`**, **`wrapper-modules`**, **Niri**, **Noctalia**, **Doom Emacs**, **Nushell**, and **Kanata**.

---

## 📖 Table of Contents
1. [Philosophy & Architecture](#1-philosophy--architecture)
2. [System Stack Overview](#2-system-stack-overview)
3. [Dendritic File Tree](#3-dendritic-file-tree)
4. [Master Keybinding & Input Architecture](#4-master-keybinding--input-architecture)
   - [A. Kanata Hardware Layer (Home Row Mods & Combos)](#a-kanata-hardware-layer-home-row-mods--combos)
   - [B. Niri Window Manager & Navigation](#b-niri-window-manager--navigation)
   - [C. Noctalia Shell & Overlays](#c-noctalia-shell--overlays)
   - [D. Doom Emacs & Native Ghostel Runner](#d-doom-emacs--native-ghostel-runner)
   - [E. Shell Abbreviations & Aliases](#e-shell-abbreviations--aliases)
5. [Daily Upkeep & Maintenance Guide](#5-daily-upkeep--maintenance-guide)
6. [Developer Workflow (Isolated DevShells)](#6-developer-workflow-isolated-devshells)
7. [Portability & Standalone Execution (`nix run`)](#7-portability--standalone-execution-nix-run)
8. [Fresh Machine Installation](#8-fresh-machine-installation)

---

## 1. Philosophy & Architecture

This configuration is structured around three core design principles:

### A. The Dendritic Pattern (`flake-parts` + `import-tree`)
Rather than maintaining bloated monolithic configuration files or fragile manual `imports = [ ... ]` arrays, the system uses **`import-tree`**. The root `flake.nix` automatically traverses `modules/`, turning every file into an isolated, composable node in the tree. Adding, removing, or testing a feature requires zero changes to the root flake.

### B. Pure Application Wrapping (`wrapper-modules`)
Applications (Niri, Noctalia, Doom Emacs, Nushell) are packaged as **self-contained derivations**. Their configuration files, runtime binaries, themes, and shell scripts are baked directly into `/nix/store`. This eliminates the *"works on my machine"* problem and allows running any app standalone on non-NixOS distributions (Arch, Ubuntu, Fedora) with a single `nix run` command.

### C. Zero Global Pollution
Global system packages contain only base terminal essentials. All compilers (Clang 18, GCC), build tools (CMake, Ninja), and Language Servers (`clangd`, `zls`, `rust-analyzer`) are injected **per-project on the fly** via `flake.nix` + `direnv`. When you exit a project directory, your environment returns to a completely clean state.

---

## 2. System Stack Overview

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Operating System** | **NixOS (Unstable)** | Deterministic, declarative Linux distribution |
| **Compositor** | **Niri** | Fluid, infinite scrollable-tiling Wayland window manager |
| **Desktop Shell** | **Noctalia** | Modern Qt/QML status bar, widget overlay, and launcher |
| **Keyboard Engine** | **Kanata** | Kernel-level evdev remapper (200ms HRM + 35ms Chords) |
| **Editor** | **Doom Emacs** | Native Wayland (`pgtk`), N Λ N O Light theme, Eglot/LSP |
| **IDE** | **Antigravity** | Electron-based dev environment (`antigravity-fhs`, FHS-wrapped, unfree) |
| **Shell** | **Nushell** | Structured data shell with Catppuccin Mocha Starship & Vi mode |
| **Terminal** | **Ghostty** & **Foot** | GPU-accelerated Wayland terminal emulators |
| **File Manager** | **Yazi** | Blazing-fast terminal file manager with async preview |
| **Browser** | **Helium Browser** | Lightweight, modern Wayland browser |
| **Display Manager** | **Greetd** | Silent autologin directly into `niri` |
| **Audio** | **PipeWire** | Real-time audio engine with WirePlumber and RTKit |
| **Typography** | **Maple Mono NF** | Monospace font with ligatures and Nerd Font glyphs |
| **Cursor** | **Bibata Modern** | Minimal, sleek 16px cursor across all surfaces |
| **Navigation** | **Zoxide** | System-wide fast directory jumping (`/run/current-system/sw/bin`) |

---

## 3. Dendritic File Tree

/etc/nixos/
├── flake.nix # Root entry point (flake-parts + import-tree)
├── flake.lock # Pinned Nixpkgs & flake inputs
├── README.md # System documentation
└── modules/
├── systems.nix # Supported architectures (x86_64-linux, aarch64-linux)
├── hosts/
│ └── castor/
│ ├── default.nix # Host definition: nixosConfigurations.castor
│ ├── configuration.nix # System services, bluetooth, pipewire, greetd, user
│ └── hardware.nix # Intel VMD early driver, NVMe UUIDs, CPU microcode
└── features/
├── niri.nix # Wrapped Niri compositor (packages.niri, apps.niri, apps.default), wallpaper-on-startup
├── noctalia.nix # Wrapped Noctalia shell & JSON state parser
├── emacs.nix # Wrapped Emacs with C++ stdlib headers & tools (apps.emacs)
├── doom/ # Bundled Doom Emacs configuration
├── nushell.nix # Wrapped Nushell (packages.nushell, apps.nushell)
├── nushell/ # Bundled Shell configuration
├── helium.nix # Helium Browser module
├── kanata.nix # Kanata kernel input daemon (HRM & Chords)
└── desktop.nix # Base CLI tools (bat, fd, ripgrep, btop, cava, yazi, fetch, zoxide) + Antigravity (unfree allowlisted)


---

## 4. Master Keybinding & Input Architecture

### A. Kanata Hardware Layer (Home Row Mods & Combos)
- **Caps Lock:** Acts purely as a dedicated **`Escape`** key.
- **Home Row Mods (200ms hold window):**
  - Left Hand: **`A`** (Alt) | **`S`** (Ctrl) | **`D`** (Super / Mod) | **`F`** (Shift)
  - Right Hand: **`J`** (Shift) | **`K`** (Super / Mod) | **`L`** (Ctrl) | **`;`** (Alt)
- **Simultaneous Combos (35ms window):**
  - **`U + I`** $\rightarrow$ `Backspace`
  - **`I + O`** $\rightarrow$ `Delete`
  - **`N + M`** $\rightarrow$ `Tab`
  - **`M + ,`** $\rightarrow$ Switch browser tab left (`Ctrl + PageUp`)
  - **`, + .`** $\rightarrow$ Switch browser tab right (`Ctrl + PageDown`)
  - **`Z + X`** $\rightarrow$ Undo (`Ctrl + Z`)
  - **`A + Z`** $\rightarrow$ Redo (`Ctrl + Shift + Z`)
  - **`X + C`** $\rightarrow$ Copy (`Ctrl + C`)
  - **`C + V`** $\rightarrow$ Paste (`Ctrl + V`)
  - **`X + V`** $\rightarrow$ Cut (`Ctrl + X`)
  - **`Z + V`** $\rightarrow$ Select All (`Ctrl + A`)

---

### B. Niri Window Manager & Navigation
*(Modifier: **`Mod`** / **`SUPER`** / **`Hold D`** / **`Hold K`**)*

#### Window Actions & Stacking
- **`SUPER + Q`**: Close focused window
- **`SUPER + F`**: Maximize active column
- **`SUPER + Shift + F`**: Toggle floating / tiling window
- **`SUPER + Shift + C`**: Center active column on screen
- **`SUPER + ,` (Comma)**: **Consume Window** (stack window to the right into current column)
- **`SUPER + .` (Period)**: **Expel Window** (eject bottom window to a new column on the right)
- **`SUPER + R`**: Cycle preset column widths (33% $\rightarrow$ 50% $\rightarrow$ 66% $\rightarrow$ 100%)
- **`SUPER + Shift + R`**: Reset window height

#### Navigation & Workspace Cycling (H, J, K, L)
- **`SUPER + H`** / **`Left Arrow`**: Focus column left
- **`SUPER + L`** / **`Right Arrow`**: Focus column right
- **`SUPER + J`**: Switch workspace **down** ($1 \rightarrow 2 \rightarrow 3$)
- **`SUPER + K`**: Switch workspace **up** ($3 \rightarrow 2 \rightarrow 1$)
- **`SUPER + Shift + J`**: Move column **down** to next workspace
- **`SUPER + Shift + K`**: Move column **up** to previous workspace
- **`SUPER + Shift + H / L`**: Move column left / right
- **`SUPER + Home` / `End`**: Jump to first / last column in the ribbon
- **`SUPER + Shift + Home / End`**: Move column to the very beginning / end of the ribbon
- **`SUPER + Ctrl + H / L`**: Shrink / expand column width (-5% / +5%)
- **`SUPER + 0..9`**: Jump directly to workspace `w0` through `w9`
- **`SUPER + Shift + 0..9`**: Move column to workspace `w0` through `w9`

#### Touchpad Gestures
- **3-Finger Swipe Left / Right**: Smooth, continuous horizontal ribbon panning
- **3-Finger Swipe Up / Down**: Smooth workspace transitions
- **4-Finger Swipe Up**: Zoomed-out workspace overview
- **`SUPER` + 2-Finger Trackpad Scroll**: Step through columns

#### Startup
- On login, niri auto-starts Noctalia, applies the Bibata cursor theme via `gsettings`, and sets the desktop wallpaper from `~/Pictures/Wallpapers/wallpaper.jpg` via Noctalia's IPC.

---

### C. Noctalia Shell & Overlays
- **`SUPER + D`**: **Toggle Noctalia App Launcher**
- **`SUPER + Tab`**: **Toggle Workspace Overview** (Native Niri Zoomed Overview)
- **`SUPER + N`**: Toggle Control Center & Notifications
- **`SUPER + Shift + B`**: Toggle Top Bar visibility
- **`SUPER + V`**: Toggle Clipboard Manager
- **`SUPER + I`**: Toggle Noctalia Settings
- **`SUPER + P`**: Toggle Session / Power Menu
- **`SUPER + Shift + L`**: Lock screen (via **Hyprlock**)

---

### D. Applications
- **`SUPER + Return`**: Open **Ghostty** (Nushell + Starship)
- **`SUPER + E`**: Open **Yazi** (Terminal File Manager)
- **`SUPER + W`**: Open **Helium Browser**
- **`SUPER + C`**: Open **Doom Emacs** (`emacsclient` instant launch)
- **`SUPER + Shift + S`**: Interactive area screenshot (copied to clipboard)
- **`Print`**: Full-screen screenshot to clipboard
- **Antigravity**: Launch via terminal (`antigravity-ide`), installed system-wide as `antigravity-fhs`

---

### E. Doom Emacs (Leader: `SPC`)
- **`SPC r r`**: **Smart Ghostel Runner** (compiles & runs C++/CMake/Python interactively in bottom popup terminal)
- **`SPC r c`**: Compile project (`compile`)
- **`SPC p p`**: Switch Projectile workspace
- **`SPC p f`**: Find file in project
- **`SPC f f`** or **`SPC .`**: Open / find any file
- **`SPC f p`**: Open private Doom config (`~/.config/doom/`)
- **`SPC g g`**: Open **Magit** (Interactive Git dashboard)
- **`SPC o t`**: Toggle **Ghostel** terminal popup (running Nushell)
- **`SPC h t`**: Switch Theme (`doom-nano-light` $\leftrightarrow$ `doom-nano-dark`)

---

### F. Shell Abbreviations & Aliases
| Abbreviation | Expanded Command |
| :--- | :--- |
| **`nr`** | `sudo nixos-rebuild switch --flake /etc/nixos#castor` |
| **`nfu`** | `nix flake update --flake /etc/nixos` |
| **`ncd`** | `cd /etc/nixos` |
| **`z <dir>`** / **`zi`** | Fast directory jumping via Zoxide / Interactive jump (system-wide) |
| **`za <dir>`** | `zoxide add <dir>` |
| **`e`** | `emacsclient -c -a 'emacs'` |
| **`y`** | `yazi` |
| **`f`** | `fetch` (3D animated rotating NixOS logo) |
| **`cat`** | `bat --paging=never` |
| **`ga`** | `git add -A` |
| **`gc "msg"`** | `git commit -m "msg"` |
| **`gp`** / **`gpu`** | `git push` / `git pull` |
| **`gst`** / **`gd`** | `git status` / `git diff` |
| **`glog`** | `git log --oneline --graph --decorate` |

---

## 5. Daily Upkeep & Maintenance Guide

### A. Updating System Configurations
1. Edit any file inside `/etc/nixos/modules/` (e.g. `v /etc/nixos/modules/features/niri.nix`).
2. Stage and commit:
```bash
   ncd
   ga
   gc "feat: describe your change"
```
3. Rebuild:
```bash
   nr
```
4. Push to GitHub:
```bash
   gp
```

### B. Updating Doom Emacs (`~/.config/doom/`)
- **Edit settings / themes (`config.el`)**:
```bash
  systemctl --user restart emacs.service
```
- **Add / remove packages (`init.el` or `packages.el`)**:
```bash
  doom sync
  systemctl --user restart emacs.service
```

---

## 6. Developer Workflow (Isolated DevShells)

A modern C++20 starter template is available at **`~/Projects/Templates/cpp-starter`**.

### Initializing a new project:
```nu
cp -r ~/Projects/Templates/cpp-starter ~/Projects/MyProject
cd ~/Projects/MyProject
direnv allow
```

`direnv` automatically injects Clang 18, LLDB, CMake, and Ninja into your shell and sets up `clangd` header indexing. Open in Doom Emacs (**`SUPER + C`** $\rightarrow$ **`SPC p p`**) and press **`SPC r r`** to run code interactively.

---

## 7. Portability & Standalone Execution (`nix run`)

Every component is packaged as a standalone derivation. Execute directly on **any Linux distribution** (Arch, Ubuntu, Fedora) with Nix installed:

```bash
# Launch wrapped Niri compositor (also the default app):
nix run github:McKaigne/dotfiles
nix run github:McKaigne/dotfiles#niri

# Launch Doom Emacs:
nix run github:McKaigne/dotfiles#emacs

# Launch Catppuccin Nushell + Starship:
nix run github:McKaigne/dotfiles#nushell
```

---

## 8. Fresh Machine Installation

To deploy on a new machine:

1. Boot any NixOS Live USB.
2. Partition and mount disks (`/mnt/boot` for EFI, `/mnt` for root).
3. Clone configuration:
```bash
   nixos-generate-config --root /mnt
   git clone https://github.com/McKaigne/dotfiles.git /mnt/etc/nixos
```
4. Update `modules/hosts/castor/hardware.nix` with the machine's disk UUIDs.
5. Install and reboot:
```bash
   nixos-install --flake /mnt/etc/nixos#castor
   reboot
```

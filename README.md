
# 🌌 Castor — Dendritic NixOS Flake

A production-grade, modular NixOS workstation engineered with **`flake-parts`**, **`import-tree`**, **`wrapper-modules`**, **Niri**, **Noctalia**, **Doom Emacs**, **Nushell**, and **Kanata**.

---

## 📖 Table of Contents
1. [Philosophy & Architecture](#1-philosophy--architecture)
2. [System Stack Overview](#2-system-stack-overview)
3. [Dendritic File Tree](#3-dendritic-file-tree)
4. [Master Keybinding & Input Architecture](#4-master-keybinding--input-architecture)
   - [A. Kanata Hardware Layer (Home Row Mods & Combos)](#a-kanata-hardware-layer-home-row-mods--combos)
   - [B. Niri Window Manager & Column Stacking](#b-niri-window-manager--column-stacking)
   - [C. Noctalia Shell & Overlays](#c-noctalia-shell--overlays)
   - [D. Doom Emacs & Native Ghostel Runner](#d-doom-emacs--native-ghostel-runner)
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
| **Keyboard Engine** | **Kanata** | Kernel-level evdev remapper (Home Row Mods + 25ms Chords) |
| **Editor** | **Doom Emacs** | Native Wayland (`pgtk`), N Λ N O Light theme, Eglot/LSP |
| **Shell** | **Nushell** | Structured data shell with Catppuccin Mocha Starship & Vi mode |
| **Terminal** | **Ghostty** & **Foot** | GPU-accelerated Wayland terminal emulators |
| **File Manager** | **Yazi** | Blazing-fast terminal file manager with async preview |
| **Browser** | **Helium Browser** | Lightweight, modern Wayland browser |
| **Display Manager** | **Greetd** | Silent autologin directly into `niri` |
| **Audio** | **PipeWire** | Real-time audio engine with WirePlumber and RTKit |
| **Typography** | **Maple Mono NF** | Rounded monospace font with ligatures and Nerd Font glyphs |
| **Cursor** | **Bibata Modern** | Minimal, sleek 16px cursor across all surfaces |

---

## 3. Dendritic File Tree

```
/etc/nixos/
├── flake.nix                                # Root entry point (flake-parts + import-tree)
├── flake.lock                               # Pinned Nixpkgs & flake inputs
├── README.md                                # This documentation
└── modules/
    ├── systems.nix                          # Supported architectures (x86_64-linux, aarch64-linux)
    ├── hosts/
    │   └── castor/
    │       ├── default.nix                  # Host definition: nixosConfigurations.castor
    │       ├── configuration.nix            # System services, bluetooth, pipewire, greetd, user
    │       └── hardware.nix                 # Intel VMD early driver, NVMe UUIDs, CPU microcode
    └── features/
        ├── niri.nix                         # Wrapped Niri compositor (packages.niri)
        ├── noctalia.nix                     # Wrapped Noctalia shell & JSON state parser
        ├── noctalia.json                    # Exported persistent GUI widget & bar state
        ├── emacs.nix                        # Wrapped Emacs with C++ stdlib headers & tools
        ├── doom/                            # Bundled Doom Emacs configuration
        │   ├── init.el                      # Core modules (corfu, eglot, tree-sitter, etc.)
        │   ├── config.el                    # N Λ N O Light, Projectile, Ghostel runner, Avy
        │   ├── packages.el                  # doom-nano-modeline, doom-nano-themes, eca
        │   └── themes/                      # doom-nano-dark & doom-nano-light theme files
        ├── nushell.nix                      # Wrapped Nushell (packages.myNushell)
        ├── nushell/                         # Bundled Shell configuration
        │   ├── config.nu                    # Nushell aliases, dark theme, vi mode
        │   ├── env.nu                       # Environment & completions setup
        │   └── starship.toml                # Catppuccin Mocha Starship prompt with Nerd Icons
        ├── helium.nix                       # Helium Browser module
        ├── kanata.nix                       # Kanata kernel input daemon (HRM & Chords)
        └── desktop.nix                      # Base CLI tools (bat, fd, ripgrep, btop, cava, yazi, fetch)
```

---

## 4. Master Keybinding & Input Architecture

### A. Kanata Hardware Layer (Home Row Mods & Combos)
Kanata intercepts physical keyboard events at the kernel `evdev` layer, meaning these shortcuts work universally across the entire operating system, TTYs, terminals, and games:

- **Caps Lock:** Acts purely as a dedicated **`Escape`** key.
- **Home Row Mods (150ms hold window):**
  - Left Hand: **`A`** (Alt) | **`S`** (Ctrl) | **`D`** (Super / Mod) | **`F`** (Shift)
  - Right Hand: **`J`** (Shift) | **`K`** (Super / Mod) | **`L`** (Ctrl) | **`;`** (Alt)
- **Simultaneous Combos (Strict 25ms window):**
  - **`U + I`** $\rightarrow$ `Backspace`
  - **`I + O`** $\rightarrow$ `Delete`
  - **`M + ,`** $\rightarrow$ `Tab`
  - **`, + .`** $\rightarrow$ Switch browser tab left (`Ctrl + PageUp`)
  - **`. + /`** $\rightarrow$ Switch browser tab right (`Ctrl + PageDown`)
  - **`Z + X`** $\rightarrow$ Undo (`Ctrl + Z`)
  - **`A + Z`** $\rightarrow$ Redo (`Ctrl + Shift + Z`)
  - **`X + C`** $\rightarrow$ Copy (`Ctrl + C`)
  - **`C + V`** $\rightarrow$ Paste (`Ctrl + V`)
  - **`X + V`** $\rightarrow$ Cut (`Ctrl + X`)
  - **`Z + V`** $\rightarrow$ Select All (`Ctrl + A`)

---

### B. Niri Window Manager & Column Stacking
*(Modifier: **`Mod`** / **`SUPER`** / **`Hold D`** / **`Hold K`**)*

#### Window Actions & Stacking
- **`SUPER + Q`**: Close focused window
- **`SUPER + F`**: Maximize active column
- **`SUPER + Shift + F`** or **`SUPER + Alt + Space`**: Toggle floating / tiling window
- **`SUPER + Alt + C`**: Center active column on screen
- **`SUPER + ,` (Comma)**: **Consume Window** (pulls window to the right into the current column, stacking vertically)
- **`SUPER + .` (Period)**: **Expel Window** (ejects bottom window to a new column on the right)
- **`SUPER + R`**: Cycle preset column widths (33% $\rightarrow$ 50% $\rightarrow$ 66% $\rightarrow$ 100%)
- **`SUPER + Shift + R`**: Reset window height

#### Navigation (Vim HJKL & Arrows)
- **`SUPER + H`** / **`Left Arrow`**: Focus column left
- **`SUPER + L`** / **`Right Arrow`**: Focus column right
- **`SUPER + K`** / **`Up Arrow`**: Focus window up (inside stacked column)
- **`SUPER + J`** / **`Down Arrow`**: Focus window down (inside stacked column)
- **`SUPER + Home`** / **`End`**: Jump to first / last column in the ribbon
- **`SUPER + Shift + H / J / K / L`**: Move active column/window in direction
- **`SUPER + Shift + Home / End`**: Move column to the very beginning / end of the ribbon

#### Resizing
- **`SUPER + Ctrl + H / L`**: Shrink / expand column width (-5% / +5%)
- **`SUPER + Ctrl + J / K`**: Shrink / expand window height (-5% / +5%)

#### Workspaces
- **`SUPER + 0..9`**: Jump to workspace `w0` through `w9`
- **`SUPER + Shift + 0..9`**: Move column to workspace `w0` through `w9`
- **`SUPER + Page_Down`**: Move to next workspace ($1 \rightarrow 2 \rightarrow 3$)
- **`SUPER + Page_Up`**: Move to previous workspace ($3 \rightarrow 2 \rightarrow 1$)
- **`SUPER + Shift + Page_Down / Up`**: Move column down / up to next workspace

#### Touchpad & Mouse Gestures
- **3-Finger Swipe Left / Right**: Smooth, continuous horizontal ribbon panning
- **3-Finger Swipe Up / Down**: Smooth workspace transitions
- **4-Finger Swipe Up**: Zoomed-out workspace overview
- **`SUPER` + 2-Finger Trackpad Scroll**: Step through columns
- **`SUPER + Ctrl` + 2-Finger Trackpad Scroll**: Step through workspaces

---

### C. Noctalia Shell & Overlays
- **`SUPER + D`**: **Toggle Noctalia App Launcher**
- **`SUPER + Tab`**: Toggle Workspace Overview
- **`SUPER + A`**: Toggle Left Sidebar
- **`SUPER + N`**: Toggle Right Sidebar (Control Center & Notifications)
- **`SUPER + Alt + B`**: Toggle Top Bar visibility
- **`SUPER + V`**: Toggle Clipboard Manager
- **`SUPER + I`**: Toggle Noctalia Settings
- **`Ctrl + Alt + Delete`**: Toggle Session / Power Menu
- **`SUPER + Alt + L`**: Lock screen (via **Hyprlock**)
- **`SUPER + Alt + Shift + L`**: Lock screen and Suspend / Sleep
- **`Ctrl + Shift + Alt + SUPER + Delete`**: Power off / Shutdown

---

### D. Applications
- **`SUPER + Return`** or **`SUPER + T`**: Open **Ghostty** (running Nushell + Starship)
- **`SUPER + E`**: Open **Yazi** (Terminal File Manager)
- **`SUPER + W`**: Open **Helium Browser**
- **`SUPER + C`**: Open **Doom Emacs** (`emacsclient` instant launch)
- **`SUPER + X`**: Open **Neovim**
- **`Ctrl + Shift + Escape`**: Open **btop** (Task Manager)
- **`SUPER + Shift + S`**: Interactive area screenshot (copied to clipboard via `grim + slurp`)
- **`Print`**: Full-screen screenshot to clipboard

---

### E. Doom Emacs (Leader: `SPC`)
- **`SPC r r`**: **Smart Ghostel Runner** (automatically detects CMake project or single `.cpp` file, compiles, and runs interactively in a bottom popup terminal with full `std::cin` support)
- **`SPC r c`**: Compile project (`compile`)
- **`SPC p p`**: Switch Projectile workspace
- **`SPC p f`**: Find file in project
- **`SPC f f`** or **`SPC .`**: Open / find any file
- **`SPC f p`**: Open private Doom config (`~/.config/doom/`)
- **`SPC g g`**: Open **Magit** (Interactive Git dashboard)
- **`SPC o t`**: Toggle **Ghostel** terminal popup (running Nushell)
- **`SPC h t`**: Switch Theme (`doom-nano-light` $\leftrightarrow$ `doom-nano-dark`)
- **`SPC j j` / `j w` / `j l`**: **Avy Jump** to char / word / line
- **`SPC a p`**: Open **ECA** AI prompt

---

## 5. Daily Upkeep & Maintenance Guide

Because `/etc/nixos/` is a Git repository, **Nix only evaluates files tracked by Git**. Follow this workflow whenever you make modifications:

### A. Updating System Configurations (Niri, Kanata, Packages, Hosts)
1. Edit any file inside `/etc/nixos/modules/` (e.g. `v /etc/nixos/modules/features/niri.nix`).
2. Stage all changes to Git:
   ```bash
   cd /etc/nixos
   git add -A
   git commit -m "feat: describe your change"
   ```
3. Rebuild and activate your system:
   ```bash
   sudo nixos-rebuild switch --flake /etc/nixos#castor
   ```
4. Push your changes to GitHub:
   ```bash
   git push
   ```

### B. Updating Doom Emacs (`~/.config/doom/`)
`~/.config/doom/` is directly symlinked to `/etc/nixos/modules/features/doom/`. Editing in one updates both automatically.

- **If you edit `config.el`** (themes, keys, settings):
  ```bash
  systemctl --user restart emacs.service
  ```
- **If you edit `init.el` or `packages.el`** (adding/removing packages):
  ```bash
  doom sync
  systemctl --user restart emacs.service
  ```
- Commit the changes:
  ```bash
  cd /etc/nixos && git add -A && git commit -m "feat(emacs): update config" && git push
  ```

### C. Persisting Noctalia GUI Adjustments
If you modify your Noctalia bar, widgets, or colors using the graphical settings menu:
```bash
# Dump active GUI settings to JSON
noctalia-shell ipc call state all > /etc/nixos/modules/features/noctalia.json 2>/dev/null || \
noctalia msg state-get > /etc/nixos/modules/features/noctalia.json

# Commit & rebuild so it becomes permanent
cd /etc/nixos
git add -A
git commit -m "style(noctalia): save persistent GUI state"
sudo nixos-rebuild switch --flake /etc/nixos#castor
```

---

## 6. Developer Workflow (Isolated DevShells)

This system contains a ready-to-use modern C++20 starter template at **`~/Projects/Templates/cpp-starter`**.

### Initializing a new project:
```nu
cp -r ~/Projects/Templates/cpp-starter ~/Projects/MyProject
cd ~/Projects/MyProject
direnv allow
```

### What happens automatically:
1. **`direnv`** activates the project `flake.nix` devshell containing Clang 18, LLDB, CMake, and Ninja.
2. `shellHook` generates `build/compile_commands.json` and supplies `CPLUS_INCLUDE_PATH`.
3. Open the project in Doom Emacs (**`SUPER + C`** $\rightarrow$ **`SPC p p`**). `clangd` provides instant autocomplete and zero missing `<iostream>` header errors.
4. Press **`SPC r r`** to run your code interactively.

---

## 7. Portability & Standalone Execution (`nix run`)

Every component in this repository is packaged as a standalone derivation under `perSystem.packages`. You can execute these on **any Linux distribution** (Arch, Ubuntu, Fedora) that has Nix installed:

```bash
# Launch the complete Doom Emacs configuration on any machine:
nix run github:<YOUR_USERNAME>/<REPO_NAME>

# Launch the Catppuccin Nushell + Starship environment:
nix run github:<YOUR_USERNAME>/<REPO_NAME>#myNushell

# Launch the wrapped Niri compositor:
nix run github:<YOUR_USERNAME>/<REPO_NAME>#niri
```

---

## 8. Fresh Machine Installation

To deploy this exact operating system on a new machine:

1. Boot any NixOS Live USB.
2. Partition and format your disks:
   - Partition 1: EFI System Partition (FAT32, mounted at `/mnt/boot`).
   - Partition 2: Root Filesystem (ext4/btrfs, mounted at `/mnt`).
3. Generate hardware config and copy the flake:
   ```bash
   nixos-generate-config --root /mnt
   git clone https://github.com/<YOUR_USERNAME>/<REPO_NAME>.git /mnt/etc/nixos
   ```
4. Update `modules/hosts/castor/hardware.nix` with the new machine's disk UUIDs.
5. Install and reboot:
   ```bash
   nixos-install --flake /mnt/etc/nixos#castor
   reboot
   ```

# Castor — Dendritic NixOS Flake Configuration

A fully reproducible, modular NixOS configuration built with **flake-parts**, **import-tree**, and **wrapper-modules**.

---

## 1. System Overview

- **Host:** `castor` (User: `pollux`)
- **Architecture:** `x86_64-linux`
- **Compositor:** Niri (Scrollable-tiling Wayland window manager, wrapped)
- **Desktop Shell & Bar:** Noctalia (Wrapped via `wrapper-modules`)
- **Default Shell:** Nushell (Wrapped with Catppuccin Mocha Starship, Vi mode, Direnv)
- **Editor:** Doom Emacs (`emacs-pgtk` wrapped with N Λ N O theme, Eglot/Clangd, Projectile)
- **Browser:** Helium Browser (via Flake)
- **File Manager:** Yazi (Terminal file explorer)
- **Terminal:** Ghostty & Foot
- **Display Manager:** `greetd` (Autologin directly to `niri`)
- **Audio:** PipeWire + WirePlumber + RTKit
- **Keyboard Remap:** Caps Lock mapped to Escape system-wide

---

## 2. File Tree (/etc/nixos/)

```
/etc/nixos/
├── flake.nix                                # Flake entry point (flake-parts + import-tree)
├── flake.lock                               # Pinned input hashes
├── README.md                                # System documentation
└── modules/
    ├── systems.nix                          # Supported architectures (x86_64-linux, aarch64-linux)
    ├── hosts/
    │   └── castor/
    │       ├── default.nix                  # nixosConfigurations.castor definition
    │       ├── configuration.nix            # System services, audio, greetd, users, xkb
    │       └── hardware.nix                 # Intel VMD module, NVMe UUIDs, CPU microcode
    └── features/
        ├── niri.nix                         # Wrapped Niri compositor (packages.niri)
        ├── noctalia.nix                     # Wrapped Noctalia shell (packages.noctalia-shell)
        ├── emacs.nix                        # Wrapped Emacs (packages.myEmacs / apps.default)
        ├── doom/                            # Bundled Doom Emacs configuration
        │   ├── init.el                      # Modules (corfu, eglot, tree-sitter, etc.)
        │   ├── config.el                    # N Λ N O theme, Projectile, Direnv, Eglot
        │   ├── packages.el                  # doom-nano-themes, modeline, quickrun, eca
        │   └── themes/                      # doom-nano-dark & doom-nano-light theme files
        ├── nushell.nix                      # Wrapped Nushell (packages.myNushell)
        ├── nushell/                         # Bundled Shell configuration
        │   ├── config.nu                    # Nushell aliases, dark theme, vi mode
        │   ├── env.nu                       # Environment & completions setup
        │   └── starship.toml                # Catppuccin Mocha Starship prompt
        ├── helium.nix                       # Helium Browser module
        └── desktop.nix                      # Desktop tools (yazi, btop, cava, fastfetch, ripgrep, fd)
```

---

## 3. Hardware & Storage Specs

- **CPU:** Intel Tiger Lake (11th Gen Core with Iris Xe Graphics)
- **Required Early Kernel Module:** `"vmd"` (Intel Volume Management Device required for NVMe controller)
- **Root Partition (/):** `/dev/disk/by-uuid/47cece7e-2fa0-4933-9b78-eb0beb9e6f22` (ext4)
- **Boot Partition (/boot):** `/dev/disk/by-uuid/0218-E6F4` (vfat / FAT32)

---

## 4. Keybindings Cheatsheet

### Niri Desktop (Modifier: Mod / Super / Windows Key)

#### Applications & Launchers
- **Mod + Space**: Toggle Noctalia Launcher
- **Mod + Return** / **Mod + T**: Open Ghostty (Nushell + Starship)
- **Mod + E**: Open Yazi File Manager
- **Mod + W**: Open Helium Browser
- **Mod + C**: Open Doom Emacs
- **Mod + X**: Open Neovim
- **Ctrl + Shift + Escape**: Open btop (Task Manager)
- **Mod + I**: Toggle Noctalia Settings

#### Window & Column Actions
- **Mod + Q**: Close active window
- **Mod + F**: Maximize active column
- **Mod + Shift + F** / **Mod + Alt + Space**: Toggle floating window
- **Mod + Alt + C**: Center column on screen
- **Mod + H / J / K / L** (or Arrows): Focus column left / down / up / right
- **Mod + Shift + H / L**: Move column left / right
- **Mod + Ctrl + H / L**: Expand / shrink column width
- **Mod + Ctrl + J / K**: Expand / shrink window height
- **Mouse Wheel**: Scroll horizontally through the infinite window ribbon

#### Workspaces
- **Mod + 0..9**: Switch to workspace w0 through w9
- **Mod + Shift + 0..9**: Move active column to workspace w0 through w9
- **Mod + Page_Down**: Move to next workspace (1 -> 2 -> 3)
- **Mod + Page_Up**: Move to previous workspace (3 -> 2 -> 1)
- **Mod + Shift + Page_Down**: Move active column down to next workspace
- **Mod + Shift + Page_Up**: Move active column up to previous workspace

#### Shell & Overlays
- **Mod + Tab**: Toggle Overview
- **Mod + A**: Toggle Left Sidebar
- **Mod + N**: Toggle Right Sidebar (Control Center)
- **Mod + Alt + B**: Toggle Top Bar
- **Ctrl + Alt + Delete**: Toggle Session / Power Menu
- **Mod + Alt + L**: Lock screen
- **Mod + Alt + Shift + L**: Suspend / Sleep
- **Ctrl + Shift + Alt + Mod + Delete**: Power off system

#### Utilities & Media
- **Mod + Shift + S**: Area screenshot (copied to clipboard)
- **Print**: Full-screen screenshot (copied to clipboard)
- **Mod + V**: Toggle Clipboard history
- **XF86AudioRaiseVolume / LowerVolume**: Adjust system volume
- **XF86AudioMute / Mod + Shift + M**: Toggle audio mute
- **XF86MonBrightnessUp / Down**: Adjust display brightness
- **Mod + Shift + P**: Play / Pause media
- **Mod + Shift + N / B**: Next / Previous media track

---

### Doom Emacs (Leader: SPC)
- **SPC p p**: Switch Projectile project
- **SPC p f**: Find file in current project
- **SPC f f** / **SPC .**: Find / open any file
- **SPC g g**: Open Magit (Git status interface)
- **SPC o t**: Toggle Ghostel terminal buffer inside Emacs
- **SPC r r**: Quickrun current code buffer
- **SPC a p**: Open ECA AI prompt
- **SPC h t**: Switch Theme (doom-nano-dark / doom-nano-light)

---

## 5. Developer Workflow (Per-Project Flakes + Direnv)

Compilers and Language Servers are injected per-project via direnv.

### Initializing a new project (e.g., C++):
Run inside your project directory:
```bash
echo "use flake" > .envrc && direnv allow
```

---

## 6. Maintenance & Rebuild Commands

Always stage changes before rebuilding so import-tree detects new files:

```bash
cd /etc/nixos
git add -A
git commit -m "feat: description of change"
sudo nixos-rebuild switch --flake /etc/nixos#castor
```

---

## 7. Portability (Running Standalone on Any Linux / Arch)

Run packages directly on any machine with Nix installed:

```bash
# Run Doom Emacs:
nix run github:<USERNAME>/<REPO>

# Run Nushell + Starship:
nix run github:<USERNAME>/<REPO>#myNushell

# Run Niri compositor:
nix run github:<USERNAME>/<REPO>#niri
```

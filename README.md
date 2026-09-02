# System Documentation & Handover Guide

This repository contains the complete NixOS flake configuration for **`castor`** (User: **`pollux`**).

---

## 1. System Overview

- **OS:** NixOS 26.11 (Zokor)
- **Architecture Standard:** [Vimjoyer's](https://www.vimjoyer.com/vid79-parts-wrapped) `flake-parts` + `import-tree` + `nix-wrapper-modules` pattern
- **Compositor:** **Niri** (Scrollable-tiling Wayland window manager, wrapped)
- **Desktop Shell:** **Noctalia** (Wrapped via `wrapper-modules`)
- **Default Shell:** **Nushell** (Wrapped with Catppuccin Mocha Starship, Vi mode, Direnv)
- **Editor:** **Doom Emacs** (`emacs-pgtk` wrapped with N Λ N O theme, Eglot/Clangd, Projectile)
- **Browser:** **Helium Browser** (via Flake)
- **Display Manager:** **Greetd** (Autologin to `niri-session`)
- **Audio:** PipeWire + WirePlumber + RTKit
- **Cursor Theme:** Bibata-Modern-Classic (Size 16)

---

## 2. File Tree (`/etc/nixos/`)

```
/etc/nixos/
├── flake.nix                                # Root Flake entry point (flake-parts + import-tree)
├── flake.lock                               # Pinned input hashes
├── README.md                                # System documentation
└── modules/
    ├── systems.nix                          # Defines supported architectures (x86_64-linux, etc.)
    ├── hosts/
    │   └── castor/
    │       ├── default.nix                  # Defines flake.nixosConfigurations.castor
    │       ├── configuration.nix            # System-wide services, audio, greetd, users
    │       └── hardware.nix                 # Kernel modules, disks, fileSystems, microcode
    └── features/
        ├── niri.nix                         # Wrapped Niri compositor (packages.niri)
        ├── noctalia.nix                     # Wrapped Noctalia shell (packages.noctalia-shell)
        ├── emacs.nix                        # Wrapped Doom Emacs (packages.myEmacs / apps.default)
        ├── doom/                            # Bundled Doom Emacs configuration
        │   ├── init.el                      # Enabled modules (corfu, eglot, tree-sitter, etc.)
        │   ├── config.el                    # N Λ N O theme, Projectile, Direnv, Eglot hooks
        │   ├── packages.el                  # doom-nano-themes, modeline, quickrun, eca
        │   └── themes/                      # doom-nano-dark & doom-nano-light theme files
        ├── nushell.nix                      # Wrapped Nushell (packages.myNushell)
        ├── nushell/                         # Bundled Shell configuration
        │   ├── config.nu                    # Nushell aliases, dark theme, vi mode
        │   ├── env.nu                       # Environment & completions setup
        │   └── starship.toml                # Catppuccin Mocha Starship prompt
        ├── helium.nix                       # Helium Browser module
        └── desktop.nix                      # Fonts (Symbola, JetBrainsMono), tools (Ghostty, Foot, Grim, Slurp)
```

---

## 3. How the Wrapped Packages Work

Every major application is packaged in `modules/features/<name>.nix` with its runtime dependencies and configuration baked into `/nix/store`:

1. **Doom Emacs (`modules/features/emacs.nix`):**
   - Bundles `clang`, `clangd`, `cmake`, `gnumake`, `git`, `ripgrep`, `fd`, `nixfmt`, `shellcheck`, and `python3` directly into Emacs' `$PATH`.
   - Bakes `DOOMDIR` pointing to the bundled configuration directory.
   - Set as `apps.default`, enabling **`nix run /etc/nixos`** (or `nix run github:<USER>/<REPO>`).

2. **Nushell (`modules/features/nushell.nix`):**
   - Bundles `starship`, `zoxide`, `carapace`, `eza`, `fzf`, `neovim`, and `direnv`.
   - Automatically loads `config.nu`, `env.nu`, and `starship.toml` without depending on mutable home directory files.
   - Run standalone with **`nix run /etc/nixos#myNushell`**.

3. **Niri (`modules/features/niri.nix`):**
   - Configured via `wrapper-modules` with Vim keys (`Mod + H/J/K/L`), dynamic window resizing, and IPC hooks into Noctalia.

---

## 4. Keybindings Cheatsheet

### Niri Desktop (Modifier: `Mod` / `Super` / `Windows Key`)
| Shortcut | Action |
| :--- | :--- |
| **`Mod + Return`** | Open **Ghostty** (Nushell + Starship) |
| **`Mod + S`** | Toggle **Noctalia Launcher** |
| **`Mod + W`** | Open **Helium Browser** |
| **`Mod + E`** | Open **Doom Emacs** |
| **`Mod + Q`** | Close focused window |
| **`Mod + F`** | Maximize column |
| **`Mod + G`** | Fullscreen window |
| **`Mod + Shift + F`** | Toggle floating window |
| **`Mod + C`** | Center column |
| **`Mod + H / J / K / L`** | Focus column left / right / up / down |
| **`Mod + Shift + H / L`** | Move column left / right |
| **`Mod + Ctrl + H / L`** | Expand / shrink column width |
| **`Mod + Ctrl + J / K`** | Expand / shrink window height |
| **`Mod + 1..9, 0`** | Switch to workspace 0–9 |
| **`Mod + Shift + 1..9, 0`** | Move column to workspace 0–9 |
| **`Mod + Shift + S`** | Area screenshot (copied to clipboard) |
| **`Mod + Ctrl + S`** | Full-screen screenshot (copied to clipboard) |
| **`Mouse Wheel`** | Scroll horizontally through the infinite window ribbon |

---

### Doom Emacs (Leader: `SPC`)
| Shortcut | Action |
| :--- | :--- |
| **`SPC p p`** | Switch Projectile project |
| **`SPC p f`** | Find file in current project |
| **`SPC f f`** or **`SPC .`** | Find / open any file |
| **`SPC g g`** | Open **Magit** (Git status interface) |
| **`SPC o t`** | Toggle **Ghostel** terminal buffer inside Emacs |
| **`SPC r r`** | **Quickrun** current code buffer |
| **`SPC a p`** | Open **ECA** AI prompt |
| **`SPC h t`** | Switch Theme (`doom-nano-dark` / `doom-nano-light`) |

---

## 5. Developer Workflow (Per-Project Flakes + Direnv)

Global packages do not contain language toolchains. Compilers and Language Servers are injected per-project via `direnv`:

### Initializing a new project (e.g., C++):
```bash
mkdir -p ~/projects/my-cpp && cd ~/projects/my-cpp

cat > flake.nix << 'EOF'
{
  description = "C++ Project Environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        llvm = pkgs.llvmPackages_18;
      in {
        devShells.default = pkgs.mkShell.override { stdenv = llvm.stdenv; } {
          packages = with pkgs; [
            llvm.clang
            llvm.clang-tools # clangd, clang-format
            llvm.lldb
            cmake
            ninja
          ];
        };
      });
}

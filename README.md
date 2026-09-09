# Castor — NixOS Workstation

## Table of Contents

1. [Dendritic & Hermetic Architecture](#1-dendritic--hermetic-architecture)
2. [Software & Packaging](#2-software--packaging)
3. [File Structure](#3-file-structure)
4. [Key Conventions](#4-key-conventions)
5. [Noctalia Theming Exception](#5-noctalia-theming-exception)
6. [Keybindings](#6-keybindings)
7. [Daily Tasks](#7-daily-tasks)
8. [Run without NixOS](#8-run-without-nixos)
9. [Install on New Machine](#9-install-on-new-machine)

---

## 1. Dendritic & Hermetic Architecture

This workstation implements the **Dendritic Pattern** combined with the **Hermetic Wrapping Doctrine**:

- **flake-parts + import-tree:** Every file in `modules/` is automatically discovered and imported as a flake-parts module. There are zero module imports in `flake.nix`.
- **No Home Manager & No Dotfiles:** Static application configurations are not symlinked into `~/.config/`. Instead, every tool is hermetically wrapped with its runtime dependencies and in-store configuration files.
- **Portability:** Applications can be run on any machine via `nix run github:McKaigne/dotfiles#<app>` without requiring NixOS or pre-existing home directory state.

---

## 2. Software & Packaging

| Function | Program | Implementation |
| :--- | :--- | :--- |
| OS | NixOS (unstable) | Dendritic system modules |
| Window Manager | Niri | Wrapped with in-store `config.kdl` + runtime Noctalia hook |
| Shell Bar / UI | Noctalia | Wrapped via `wrapper-modules` |
| Key Remapper | Kanata | `services.kanata` (home-row mods, combos) |
| Primary Editor | Doom Emacs | Wrapped with compiler/LSP toolchains & in-store `DOOMDIR` |
| Secondary Editor | Helix (`hx`) | Wrapped with in-store `config.toml` (all-mode block cursors) |
| Shell | Nushell | Wrapped with in-store `config.nu`, `env.nu`, and Starship |
| Terminal | Ghostty | Wrapped with in-store config & GLSL smear shader |
| Multiplexer | Tmux | Wrapped with in-store `tmux.conf` & `dotbar` plugin |
| File Managers | Thunar, Yazi | Thunar via system `/etc/xdg`, Yazi hermetically wrapped |
| Audio Visualizer | CAVA | Wrapped with in-store audio configuration |
| Launcher | Fuzzel | Wrapped with in-store INI + runtime Noctalia hook |
| Web Browser | Helium | Wrapped with Ozone Wayland and GSettings schemas |
| Audio Server | PipeWire | PipeWire + WirePlumber + Intel SOF DSP Firmware |
| Cursor Theme | Bibata Modern Classic | System-wide via `cursor.nix` (legacy X11 fixes) |
| Font | Maple Mono NF | `fonts.packages` |

---

## 3. File Structure
/etc/nixos/
├── flake.nix # Flake inputs and import-tree call only
├── flake.lock # Pinned lockfile
├── README.md # System documentation
└── modules/
├── systems.nix # Target architectures (x86_64-linux, aarch64-linux)
├── hosts/castor/ # Host configuration, hardware mounts, system default
│ ├── configuration.nix
│ ├── hardware.nix
│ └── default.nix
└── features/ # Dendritic feature modules:
├── user.nix # options.mainUser (pollux)
├── cursor.nix # options.cursor (Bibata-Modern-Classic, dconf)
├── desktop.nix # Core desktop packages, fonts, MIME associations
├── emacs/ # In-store Doom Emacs configuration tree
├── emacs.nix # Wrapped Emacs derivation (LLVM 18, GCC, DOOMDIR)
├── ghostty.nix # Wrapped Ghostty with embedded GLSL smear shader
├── helix.nix # Wrapped Helix with in-store config.toml
├── helium.nix # Wrapped browser with GTK3/GSettings support
├── kanata.nix # Remapper (home-row mods, word navigation combos)
├── niri.nix # Wrapped Niri compositor with in-store config.kdl
├── noctalia.nix # Wrapped Noctalia shell package
├── nushell.nix # Wrapped Nushell with in-store config.nu, env.nu, starship
├── thunar.nix # Thunar + xfconf + archive backends + /etc/xdg actions
├── tmux.nix # Wrapped Tmux with in-store tmux.conf and dotbar
├── yazi.nix # Wrapped Yazi with in-store yazi.toml
├── cava.nix # Wrapped CAVA with in-store audio config
└── fuzzel.nix # Wrapped Fuzzel launcher with in-store fuzzel.ini
---

## 4. Key Conventions

1. **User Parameterization:** Configured via `options.mainUser` in `modules/features/user.nix`. All modules reference `config.mainUser`.
2. **Dendritic Cohesion:** Feature derivations, apps, packages, and system modules live together in `modules/features/<name>.nix`.
3. **Nix Multiline String Escaping:** Literal `${...}` inside `'' ... ''` multiline strings must be escaped as `''${...}`.
4. **No Static Dotfiles:** Do not create static files in `~/.config/`. Embed configurations into feature wrappers.

---

## 5. Noctalia Theming Exception

The only files residing in `~/.config/` are dynamic theme files generated at runtime by Noctalia shell when switching wallpapers:

- `~/.config/niri/noctalia.kdl` $\rightarrow$ Included dynamically by Niri (`include optional=true`).
- `~/.config/fuzzel/themes/noctalia` $\rightarrow$ Included dynamically by Fuzzel.
- `~/.config/gtk-3.0/noctalia.css` & `4.0` $\rightarrow$ Imported system-wide via `/etc/xdg/gtk-*/gtk.css`.

---

## 6. Keybindings

### 6.1 Kanata Home-Row Mods & Combos

| Key | Tap | Hold |
| :--- | :--- | :--- |
| A | a | Left Alt |
| S | s | Left Ctrl |
| D | d | Left Super |
| F | f | Left Shift |
| J | j | Right Shift (120 ms) |
| K | k | Right Super (120 ms) |
| L | l | Right Ctrl |
| ; | ; | Right Alt |

| Combos | Action |
| :--- | :--- |
| U + I | Ctrl + Backspace (Delete Word Left) |
| I + O | Ctrl + Delete (Delete Word Right) |
| N + M | Tab |
| M + , | Tab Left (Ctrl + PgUp) |
| , + . | Tab Right (Ctrl + PgDn) |
| Z + X | Undo |
| A + Z | Redo |
| X + C | Copy |
| C + V | Paste |
| X + V | Cut |
| Z + V | Select All |

### 6.2 Niri Compositor

| Key | Action |
| :--- | :--- |
| Mod + Return | Open Ghostty |
| Mod + E | Open Thunar |
| Mod + W | Open Helium |
| Mod + C | Open Emacs client |
| Mod + D | Toggle Noctalia launcher |
| Mod + N | Toggle Noctalia control center |
| Mod + V | Toggle Noctalia clipboard |
| Mod + I | Toggle Noctalia settings |
| Mod + P | Toggle Noctalia session menu |
| Mod + T | Toggle Noctalia wallpaper switcher |
| Mod + Shift + B | Toggle Noctalia bar |
| Mod + Shift + S | Screenshot region |
| Mod + Q | Close window |
| Mod + F | Maximize column |
| Mod + H / L | Focus column left / right (pointer warps to center) |
| Mod + J / K | Focus workspace down / up |
| Mod + 0–9 | Switch workspace w0–w9 |

---

## 7. Daily Tasks

### Edit a Feature or App Configuration
```bash
e /etc/nixos/modules/features/ghostty.nix
ga
nix flake check --no-build
nr
gc "feat(ghostty): update terminal settings"
gp
```

---

## 8. Run without NixOS

All primary tools can be run on any Linux distribution with Nix:

```bash
nix run github:McKaigne/dotfiles#helix
nix run github:McKaigne/dotfiles#ghostty
nix run github:McKaigne/dotfiles#tmux
nix run github:McKaigne/dotfiles#yazi
nix run github:McKaigne/dotfiles#nushell
nix run github:McKaigne/dotfiles#emacs
nix run github:McKaigne/dotfiles          # Launch Niri session
```

---

## 9. Install on New Machine

1. Boot live USB and mount partitions to `/mnt`.
2. Clone repository:
   ```bash
   git clone https://github.com/McKaigne/dotfiles.git /mnt/etc/nixos
   ```
3. Update disk UUIDs in `modules/hosts/castor/hardware.nix`.
4. Install:
   ```bash
   nixos-install --flake /mnt/etc/nixos#castor
   ```
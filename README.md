# Castor — NixOS Workstation

## Table of Contents

1. [Dendritic system](#1-dendritic-system)
2. [Software](#2-software)
3. [File structure](#3-file-structure)
4. [Key conventions](#4-key-conventions)
5. [The dotfiles system](#5-the-dotfiles-system)
6. [Keybindings](#6-keybindings)
7. [Daily tasks](#7-daily-tasks)
8. [Run without NixOS](#8-run-without-nixos)
9. [Install on new machine](#9-install-on-new-machine)

---

## 1. Dendritic system

Every file in `modules/` is discovered and imported automatically via `import-tree` into `flake-parts`.

- `flake-parts`: Structures modular outputs (`flake.*`, `perSystem.*`).
- `import-tree`: Recursively discovers `.nix` files without manual imports in `flake.nix`.
- `wrapper-modules`: Packages applications (Niri, Noctalia, Nushell, Emacs, Helium) with bundled dependencies.
- `home-manager`: Links `dotfiles/` to `~/.config` via out-of-store symlinks.

---

## 2. Software

| Function | Program |
| :--- | :--- |
| OS | NixOS (unstable) |
| Window Manager | Niri (wrapped, mouse warp to center, auto-hide cursor) |
| Shell Bar / UI | Noctalia (wrapped, persistent state in `~/.local/state/noctalia`) |
| Key Remapper | Kanata |
| Text Editor | Doom Emacs (wrapped with GCC, LSP tools, doom-nano-light theme) |
| Default Editor | `emacsclient` |
| Shell | Nushell (wrapped) |
| Terminal | Ghostty, Foot |
| File Manager | Thunar (Adwaita icons + xfconf), Yazi |
| Web Browser | Helium (wrapped Wayland + cursor) |
| Video Editor | Kdenlive (`kdePackages.kdenlive`) |
| Media Player | MPV |
| Screen Recording | OBS Studio |
| Audio Server | PipeWire + WirePlumber + Intel SOF Firmware |
| Cursor Theme | Bibata Modern Classic (via `options.cursor` in `cursor.nix`) |
| Font | Maple Mono NF |

---

## 3. File structure

```
/etc/nixos/
├── flake.nix            # Flake inputs and import-tree call
├── flake.lock           # Pinned lockfile
├── README.md            # System documentation
├── dotfiles/            # Out-of-store live config files
└── modules/
    ├── systems.nix      # Target architectures
    ├── hosts/castor/    # Host config, hardware mounts, user
    └── features/        # Dendritic system features
```

---

## 4. Key conventions

1. **Username:** Set once in `options.mainUser` (`home-manager.nix`). All modules use `config.mainUser`.
2. **Dotfiles Path:** Centralized as `config.dotfiles.path` (defaults to `/etc/nixos/dotfiles`).
3. **Cursor:** Centralized in `cursor.nix` (`options.cursor.theme`, `options.cursor.size`, `options.cursor.package`).
4. **Linter:** Always run `nix flake check --no-build` before committing.

---

## 5. The dotfiles system

Home Manager links `~/.config/<name>` directly to `/etc/nixos/dotfiles/<name>`. Changes in `dotfiles/` take effect immediately without rebuilds.

---

## 6. Keybindings

### 6.1 Niri

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
| Mod + Shift + B | Toggle Noctalia bar |
| Mod + Shift + S | Screenshot region |
| Mod + Q | Close window |
| Mod + F | Maximize column |
| Mod + H / L | Focus left / right (warps mouse to center) |
| Mod + J / K | Focus workspace down / up |
| Mod + 0–9 | Switch workspace w0–w9 |

### 6.2 Nushell Shortcuts

| Command | Action |
| :--- | :--- |
| `nr` | Rebuild system (`sudo nixos-rebuild switch --flake /etc/nixos#castor`) |
| `nfu` | Update flake inputs |
| `ncd` | `cd /etc/nixos` |
| `e <file>` | Open graphical Emacs client |
| `et <file>` | Open terminal Emacs client |
| `v <file>` | Alias to `e` |
| `ga` | `git add -A` |
| `gc "msg"` | `git commit -m "msg"` |
| `gp` | `git push` |

---

## 7. Daily tasks

### Edit system setting
```bash
e /etc/nixos/modules/features/foo.nix
nix flake check --no-build
ga
nr
gc "feat(foo): describe change" && gp
```

### Edit dotfile
```bash
e /etc/nixos/dotfiles/ghostty/config
```

---

## 8. Run without NixOS

```bash
nix run github:McKaigne/dotfiles          # Niri
nix run github:McKaigne/dotfiles#emacs    # Doom Emacs
nix run github:McKaigne/dotfiles#nushell  # Nushell
```

---

## 9. Install on new machine

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
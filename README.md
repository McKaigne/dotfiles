# Castor & Pollux Workstations

Declarative NixOS flake architecture powering twin production workstations.

## Hosts

* **castor** (Laptop): Intel Iris Xe | User: `pollux` | Power-optimized profile (`thermald`, PPD, Wi-Fi powersave, aggressive ZRAM).
* **pollux** (Desktop): AMD Ryzen 5800X + RX 7600 XT | User: `castor` | ROCm/HIP compute for Blender Cycles, low-latency sysctl.

## Core Stack

* **Compositor:** Niri (scrollable-tiling Wayland) + Greetd autologin
* **Desktop Shell:** Noctalia (Material 3 dynamic theming with live D-Bus/GSettings portal broadcast)
* **Terminal & Shell:** Ghostty + Nushell + Starship + Zellij
* **Editor:** Helix (`hx`) with pre-bundled language servers
* **Browser:** Brave Origin (Vimium C, declarative enterprise policies, uBlock Origin MV2)
* **Remapper:** Kanata (Home Row Mods on `ASDF` / `JKL;`, Space-held Nav Layer)

## Essential Keybinds (Niri)

* `Mod + Return` — Terminal (Ghostty)
* `Mod + W` — Primary Browser (Brave Origin)
* `Mod + S` — Interactive Area Screenshot (Drag)
* `Mod + E` — File Manager (Nautilus)
* `Mod + D` — Application Launcher (Noctalia)
* `Mod + ,` — Settings (Noctalia)
* `Mod + A` — Zellij Workspace Sessionizer
* `Mod + V` — Clipboard History Panel
* `Mod + Q` — Close Focused Window
* `Mod + F` — Maximize Column Width
* `Mod + Shift + F` — Fullscreen Window
* `Mod + H / J / K / L` — Focus Left / Down / Up / Right
* `Mod + Shift + H / J / K / L` — Move Column Left / Down / Up / Right
* `Mod + 1 .. 0` — Switch Workspace `w1` .. `w0`

## Repository Structure

    /etc/nixos/
    ├── flake.nix        # System flake and host targets
    ├── hosts/           # castor (laptop) & pollux (desktop)
    ├── wallpapers/      # Declarative wallpaper assets
    └── modules/         # core, desktop, browser, terminal, editor,
                         # hardware, media, creative, dev, documents

## Rebuild & Maintenance

Stage all changes first (pure flake evaluation):
    cd /etc/nixos
    git add -A

Rebuild Laptop (castor):
    sudo nixos-rebuild switch --flake /etc/nixos#castor

Rebuild Desktop (pollux):
    sudo nixos-rebuild switch --flake /etc/nixos#pollux

Hot-reload Niri layout:
    niri msg action load-config-file

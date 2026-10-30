# NixOS Workstations: Hyde & Castor

Declarative NixOS configuration for workstations hyde and castor.

## Hosts

- **hyde**: AMD GPU, ROCm compute, user jekyll.
- **castor**: Intel Iris Xe, mobile efficiency profile, user pollux.

## Core Stack

- **Compositor**: Niri (scrollable tiling, 0px radius, 3px borders, 16px gaps, snappy animations).
- **Shell**: Noctalia (top bar, plugins: bitwarden, cheatsheet, lid-guard, obs-control).
- **Font**: Cozette bitmap (.otb), 1.0 line height, large integer scaling.
- **Theme**: Catppuccin Mocha transparent (0.85 opacity, dual-pass GPU blur).
- **Editor**: Helix (modal editing, system clipboard by default, relative numbers, multiple bufferline).
- **Multiplexer**: Zellij (borderless panes, simplified UI, session serialization).
- **Interactive Shell**: Fish (vi mode, Alt-e / Ctrl-x Ctrl-e editor buffer open, clast / chist).
- **Browser**: LibreWolf with pinned extensions from Nix store, Tridactyl, sharp CSS.

## Deployment

Remote deployment runs over Tailscale with hyde as the build host.

- `nr [host]`: switch generation
- `ntest [host]`: test generation
- `nboot [host]`: set next boot

## Keybindings Summary

- `Mod + Space`: Maximize column width
- `Mod + Shift + Space`: Fullscreen window
- `Mod + Ctrl + Space`: Toggle window floating
- `Mod + Alt + Space`: Toggle focus floating/tiling
- `Mod + F`: Foot terminal (Shift: Zellij sessionizer, Ctrl: Ghostty)
- `Mod + D`: LibreWolf (Shift: Brave, Ctrl: Private)
- `Mod + S`: PCManFM
- `Mod + A`: Ferdium (Shift: Niri overview)
- `Mod + G`: Obsidian
- `Mod + T`: Screenshot area (Shift: Fullscreen)
- `Mod + E`: Noctalia notifications (Shift: Clear history, Mod + X: Dismiss)
- `Mod + V`: Noctalia settings (Shift: Clipboard panel)
- `Mod + C`: Noctalia control center (Shift: Pavucontrol)
- `Mod + B`: Bitwarden Desktop (Shift: Noctalia Bitwarden panel, Ctrl: Bluetooth)
- `Mod + W`: Noctalia wallpaper selector (Shift: Wi-Fi panel, Ctrl: Toggle bar)
- `Mod + R`: OBS Studio (Shift: Noctalia OBS control panel)
- `Mod + ;`: Noctalia app launcher
- `Mod + /`: Noctalia keybind cheatsheet
- `Mod + Esc`: Session menu (Shift: Lock screen, Ctrl: Display power off)
- `Mod + Q`: Close window
- `Mod + H / J / K / L`: Focus column / workspace
- `Mod + Shift + H / J / K / L`: Move column / workspace
- `Mod + Ctrl + H / L`: Resize column width
- `Mod + U / I`: Focus window stack up / down
- `Mod + 1..9, 0`: Workspaces 1 through 10


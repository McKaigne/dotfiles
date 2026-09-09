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
- **Declarative Keymap Generation:** Follows Vimjoyer's declarative pattern (`pkgs.writeText` + `lib.generators.toYAML` + `pkgs.writeShellScriptBin`), compiling YAML configs directly into `/nix/store/` without runtime scripting or file mutations.
- **Hermetic Store Interpolation:** Keybindings, system actions, and openers reference exact `/nix/store` binary derivations (`${lib.getExe ...}`), eliminating ambient `$PATH` dependency.
- **Portability:** Applications can be run on any machine via `nix run github:McKaigne/dotfiles#<app>` without requiring NixOS or pre-existing home directory state.

---

## 2. Software & Packaging

| Function | Program | Implementation |
| :--- | :--- | :--- |
| OS | NixOS (unstable) | Dendritic system modules |
| Window Manager | Niri | Wrapped with in-store `config.kdl` + runtime Noctalia hook |
| Modal Keymap Menu | wlr-which-key | Declaratively wrapped with in-store YAML (centered 2-column grid, sharp 4px corners, thin 1px border) |
| Shell Bar / UI | Noctalia | Wrapped via `wrapper-modules` |
| Key Remapper | Kanata | `services.kanata` (home-row mods, universal CUA clipboard combos) |
| Primary Editor | Doom Emacs | Wrapped with compiler/LSP toolchains & in-store `DOOMDIR` |
| Secondary Editor | Helix (`hx`) | Wrapped with in-store `config.toml` (all-mode block cursors) |
| Shell | Nushell | Wrapped with in-store `config.nu`, `env.nu`, and Starship |
| Terminal | Ghostty | Wrapped with in-store config & GLSL smear shader |
| Multiplexer | Tmux | Wrapped with in-store `tmux.conf` & `dotbar` plugin |
| System Fetchers | fetch, fastfetch | `fetch` (3D animated spinning Nix relief, alias `f`) & `fastfetch` (alias `ff`) |
| File Managers | Thunar, Yazi | Thunar via `/etc/xdg` actions, Yazi hermetically wrapped with Helix |
| Audio Visualizer | CAVA | Wrapped with in-store audio configuration |
| Launcher | Fuzzel | Wrapped with in-store INI + runtime Noctalia hook |
| Web Browser | Helium | Wrapped with Ozone Wayland and GSettings schemas |
| Audio Server | PipeWire | PipeWire + WirePlumber + Intel SOF DSP Firmware |
| Cursor Theme | Bibata Modern Classic | System-wide via `cursor.nix` (legacy X11 fixes) |
| Font | Maple Mono NF | `fonts.packages` |

---

## 3. File Structure

```text
/etc/nixos/
├── flake.nix              # Flake inputs and import-tree call only
├── flake.lock             # Pinned lockfile
├── README.md              # System documentation
└── modules/
    ├── systems.nix        # Target architectures (x86_64-linux, aarch64-linux)
    ├── hosts/castor/      # Host configuration, hardware mounts, system default
    │   ├── configuration.nix
    │   ├── hardware.nix
    │   └── default.nix
    └── features/          # Dendritic feature modules:
        ├── user.nix           # options.mainUser (pollux)
        ├── cursor.nix         # options.cursor (Bibata-Modern-Classic, dconf)
        ├── desktop.nix        # Core desktop packages, fonts, MIME associations
        ├── emacs/             # In-store Doom Emacs configuration tree
        ├── emacs.nix          # Wrapped Emacs derivation (LLVM 18, GCC, DOOMDIR)
        ├── ghostty.nix        # Wrapped Ghostty with embedded GLSL smear shader
        ├── helix.nix          # Wrapped Helix with in-store config.toml
        ├── helium.nix         # Wrapped browser with GTK3/GSettings support
        ├── kanata.nix         # Remapper (home-row mods, CUA clipboard combos)
        ├── niri.nix           # Wrapped Niri compositor with in-store config.kdl
        ├── wlr-which-key.nix  # Declaratively wrapped modal menu (Vimjoyer pattern)
        ├── noctalia.nix       # Wrapped Noctalia shell package
        ├── nushell.nix        # Wrapped Nushell with in-store config.nu, env.nu, starship
        ├── thunar.nix         # Thunar + xfconf + archive backends + interpolated uca.xml
        ├── tmux.nix           # Wrapped Tmux with in-store tmux.conf and dotbar
        ├── yazi.nix           # Wrapped Yazi with interpolated Helix opener
        ├── cava.nix           # Wrapped CAVA with in-store audio config
        └── fuzzel.nix         # Wrapped Fuzzel launcher with in-store fuzzel.ini
```

---

## 4. Key Conventions

1. **User Parameterization:** Configured via `options.mainUser` in `modules/features/user.nix`. All modules reference `config.mainUser`.
2. **Dendritic Cohesion:** Feature derivations, apps, packages, and system modules live together in `modules/features/<name>.nix`.
3. **Nix Multiline String Escaping:** Literal `${...}` inside `'' ... ''` multiline strings must be escaped as `''${...}`.
4. **No Static Dotfiles:** Do not create static files in `~/.config/`. Embed configurations into feature wrappers.
5. **Direct Store Interpolation:** Keybindings in Niri and launcher configurations interpolate direct `/nix/store` paths (`${lib.getExe ...}`) to eliminate ambient `$PATH` dependency.

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

| Combos | Action | Standard |
| :--- | :--- | :--- |
| X + C | Universal Copy | `Ctrl + Insert` (CUA Standard — works in terminal & GUI) |
| C + V | Universal Paste | `Shift + Insert` (CUA Standard — works in terminal & GUI) |
| X + V | Universal Cut | `Shift + Delete` (CUA Standard — works in terminal & GUI) |
| Z + V | Select All | `Ctrl + A` |
| Z + X | Undo | `Ctrl + Z` |
| A + Z | Redo | `Ctrl + Shift + Z` |
| U + I | Delete Word Left | `Ctrl + Backspace` |
| I + O | Delete Word Right | `Ctrl + Delete` |
| N + M | Tab | `Tab` |
| M + , | Tab Left | `Ctrl + PageUp` |
| , + . | Tab Right | `Ctrl + PageDown` |

---

### 6.2 Niri Compositor (Direct & Emergency Binds)

| Key Chord | Action |
| :--- | :--- |
| `Mod + Return` | Open Ghostty terminal |
| `Mod + E` | Open Thunar file manager |
| `Mod + W` | Open Helium web browser |
| `Mod + C` | Open Doom Emacs client |
| `Mod + Space` | **Open `wlr-which-key` modal menu** |
| `Mod + D` | Quick toggle Noctalia app launcher |
| `Mod + -` | Expand window width left (`set-column-width "-5%"`) |
| `Mod + =` | Expand window width right (`set-column-width "+5%"`) |
| `Mod + .` | Open emoji picker (`bemoji` via Fuzzel) |
| `Mod + ,` | Dismiss most recent desktop notification |
| `Mod + Q` | Close window |
| `Mod + F` | Maximize column |
| `Mod + Shift + F` | Toggle window floating |
| `Mod + Shift + C` | Center column |
| `Mod + R` | Switch preset column width |
| `Mod + Shift + R` | Reset window height |
| `Mod + H` / `L` | Focus column left / right (pointer warps to center) |
| `Mod + Shift + H` / `L` | Move column left / right |
| `Mod + J` / `K` | Focus workspace down / up |
| `Mod + Shift + J` / `K` | Move column to workspace down / up |
| `Mod + 0–9` | Switch workspace w0–w9 |
| `Mod + Shift + 0–9` | Move column to workspace w0–w9 |
| `Mod + Shift + S` | Screenshot region (grim + slurp $\rightarrow$ clipboard) |
| `Print` | Screenshot output (grim $\rightarrow$ clipboard) |

---

### 6.3 Modal Keymap Menu (`Mod + Space`)

Triggered via `Mod + Space`, the on-screen menu opens a centered, 2-column grid with sharp 4px corners, a thin 1px Noctalia accent border, and mnemonic tree names:

```text
[Mod + Space] (Leader Key)
 ├── [󱁐] ──> Launcher (Noctalia App Launcher via Spacebar)
 │
 ├── [t] ──> Terminal
 │    ├── a: Tmux Attach (Ghostty)
 │    ├── g: Lazygit (Ghostty)
 │    ├── d: Lazydocker (Ghostty)
 │    ├── h: Herdr Multiplexer
 │    └── b: Btop System Monitor
 │
 ├── [l] ──> LocalSend
 │    ├── c: Send Clipboard Content
 │    ├── f: Send File (via Zenity chooser)
 │    ├── d: Send Folder (via Zenity chooser)
 │    └── r: Receive (Open App)
 │
 ├── [n] ──> Noctalia
 │    ├── l: Night Light Toggle (Manual 4000K)
 │    ├── a: Night Light Auto (Geo-coordinates)
 │    ├── s: Silence Notifications (DND Toggle)
 │    ├── c: Clipboard History
 │    ├── p: Color Picker (Hyprpicker $\rightarrow$ notification & clipboard)
 │    ├── o: OCR Extraction (Slurp $\rightarrow$ Tesseract $\rightarrow$ clipboard)
 │    └── b: Toggle Bar
 │
 ├── [w] ──> Window
 │    ├── o: Only Current Window (Close all other windows in workspace)
 │    ├── c: Close All Windows in Column
 │    ├── t: Toggle Float / Tile
 │    ├── f: Fullscreen Window
 │    ├── w: Maximize Width (Full column)
 │    ├── e: Reset Height
 │    ├── ,: Consume into Column
 │    └── .: Expel from Column
 │
 └── [s] ──> System
      ├── s: Power Menu (Noctalia session menu via Leader + s + s)
      ├── l: Lock Screen
      ├── z: Suspend System
      └── r: Reboot System
```

---

### 6.4 Shell Aliases & Utilities

| Command / Alias | Action |
| :--- | :--- |
| `f` or `fetch` | Render animated 3D rotating NixOS logo (`areofyl/fetch`) |
| `ff` | Run Fastfetch |
| `lt` | Tree listing via `eza` |
| `cat` | Bat with paging disabled |
| `e` / `et` | Emacsclient GUI (`-c`) / Terminal (`-t`) |
| `fm` | Open Thunar file manager |
| `y` | Open Yazi file manager (with wrapped Helix opener) |
| `h` / `hx` | Open Helix modal editor |
| `nr` | `sudo nixos-rebuild switch --flake /etc/nixos#castor` |
| `nfu` | `nix flake update --flake /etc/nixos` |
| `ncd` | `cd /etc/nixos` |

---

## 7. Daily Tasks

### Edit a Feature or App Configuration
```bash
e /etc/nixos/modules/features/wlr-which-key.nix
ga
nix flake check --no-build
nr
gc "feat(which-key): update custom workflow chords"
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
nix run github:McKaigne/dotfiles#wlr-which-key
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
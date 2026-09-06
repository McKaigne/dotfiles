
# Castor — NixOS Workstation

> **For future agents:** Read this entire file first. It explains the architecture, all active patterns, known gotchas, and how every piece fits together. Pay particular attention to §1 (dendritic system) and §9 (agent notes).

---

## Table of Contents

1. [Dendritic system — how this flake works](#1-dendritic-system--how-this-flake-works)
2. [Software](#2-software)
3. [File structure](#3-file-structure)
4. [Key conventions and invariants](#4-key-conventions-and-invariants)
5. [The dotfiles system](#5-the-dotfiles-system)
6. [Cursor handling](#6-cursor-handling)
7. [Keybindings](#7-keybindings)
8. [Daily tasks](#8-daily-tasks)
9. [Notes for future agents — bugs fixed, gotchas, rules](#9-notes-for-future-agents--bugs-fixed-gotchas-rules)
10. [Run a program without NixOS](#10-run-a-program-without-nixos)
11. [Install on a new machine](#11-install-on-a-new-machine)

---

## 1. Dendritic system — how this flake works

The "dendritic system" means every file in `modules/` is loaded automatically. You never touch `flake.nix` to add a new module. Three tools make this work together:

### 1.1 `flake-parts`

`flake-parts` structures the flake outputs. Every file in `modules/` receives the flake-parts context: `{ self, inputs, ... }`. Inside that context you can define `flake.*` keys (e.g. `flake.nixosModules.foo`) or `perSystem` keys (e.g. `perSystem.packages.bar`).

### 1.2 `import-tree`

`import-tree` discovers every `.nix` file under `modules/` and imports it. This is wired in `flake.nix`:

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake
  { inherit inputs; }
  (inputs.import-tree ./modules);
```

**Rule:** Drop a new `.nix` file anywhere in `modules/` and it is automatically part of the flake. No registration needed.

### 1.3 `wrapper-modules`

Some programs (Niri, Noctalia-shell, Nushell, Emacs, Helium) are built as wrapped packages using `symlinkJoin + makeWrapper` or the `wrapper-modules` library. The resulting package:
- Bundles runtime dependencies into `PATH`
- Injects environment variables (cursor, Wayland flags, etc.)
- Can be run with `nix run .#<name>` on any Linux with Nix — no NixOS required

`wrapper-modules` follows `nixpkgs` (pinned in `flake.nix`) to prevent version drift.

### 1.4 Home Manager

Home Manager is imported as a NixOS module (not standalone). It is configured in `modules/features/home-manager.nix`. It links files from `dotfiles/` into `~/.config` using **out-of-store symlinks** so you can edit them live.

### 1.5 Module loading chain for `castor`

```
flake.nix
  └── import-tree ./modules
        └── modules/hosts/castor/default.nix
              └── flake.nixosConfigurations.castor
                    └── nixosModules.castorConfiguration   (configuration.nix)
                          ├── nixosModules.castorHardware
                          ├── nixosModules.homeManager
                          ├── nixosModules.niri
                          ├── nixosModules.nushell
                          ├── nixosModules.emacs
                          ├── nixosModules.helium
                          ├── nixosModules.desktop
                          ├── nixosModules.kanata
                          ├── nixosModules.thunar
                          └── nixosModules.cursor
```

---

## 2. Software

| Function | Program |
| :--- | :--- |
| Operating system | NixOS (unstable channel) |
| Window manager | Niri (via wrapper-modules) |
| Desktop shell | Noctalia (via wrapper-modules) |
| Key remapper | Kanata |
| Text editor | Doom Emacs (wrapped) |
| Shell | Nushell (wrapped) |
| Terminal | Ghostty, Foot |
| File manager | Thunar (default GUI), Yazi (terminal) |
| Web browser | Helium (wrapped with Wayland + cursor) |
| IDE | Antigravity |
| Login manager | Greetd (autologin → Niri) |
| Audio server | PipeWire |
| Font | Maple Mono NF |
| Cursor theme | Bibata Modern Classic (centralized in `cursor.nix`) |
| Directory jumper | Zoxide |

---

## 3. File structure

```
/etc/nixos/
├── flake.nix            # Only inputs + import-tree call. Never add modules here.
├── flake.lock           # Pinned input revisions.
├── README.md            # This file — architecture reference.
├── dotfiles/            # Live config files linked into ~/.config by Home Manager.
│   ├── doom/            # Doom Emacs config (config.el, init.el, packages.el, themes/)
│   ├── nushell/         # config.nu, env.nu
│   ├── starship/        # starship.toml
│   ├── fuzzel/          # fuzzel.ini
│   ├── cava/            # config
│   ├── ghostty/         # config
│   ├── gtk-3.0/         # gtk.css
│   ├── gtk-4.0/         # gtk.css
│   └── niri/            # config.kdl (Niri reads this directly from ~/.config)
└── modules/
    ├── systems.nix      # Declares supported systems: x86_64-linux + aarch64-linux
    ├── hosts/
    │   └── castor/
    │       ├── default.nix        # Builds nixosConfigurations.castor
    │       ├── configuration.nix  # Host settings: user, greetd, pipewire, bluetooth…
    │       └── hardware.nix       # Disk UUIDs, CPU microcode, filesystem mounts
    └── features/
        ├── cursor.nix       # ★ Centralized cursor: bibataFixed pkg, env vars, dconf
        ├── home-manager.nix # HM import, options.mainUser, options.dotfiles.path, xdg links
        ├── niri.nix         # Niri NixOS module + perSystem wrapper package + keybindings
        ├── noctalia.nix     # Noctalia-shell perSystem package (wrapper-modules)
        ├── emacs.nix        # Emacs NixOS module + perSystem wrapped package
        ├── nushell.nix      # Nushell NixOS module + perSystem wrapped package
        ├── helium.nix       # Helium NixOS module (wrapped with Wayland + cursor)
        ├── kanata.nix       # Kanata: home row mods + combos
        ├── thunar.nix       # Thunar + plugins + gvfs + tumbler + xdg.mime defaults
        └── desktop.nix      # Base system packages, fonts, hyprlock PAM, allowUnfree
```

---

## 4. Key conventions and invariants

### 4.1 Never hardcode the username

The username `pollux` is set **once**: as the default value of `options.mainUser` in `home-manager.nix`. Every other module that needs the username must reference `config.mainUser`. Current usages:
- `home-manager.users.${config.mainUser}` → `home-manager.nix`
- `users.users.${config.mainUser}` → `configuration.nix`
- `services.greetd.settings.default_session.user = config.mainUser` → `configuration.nix`

To rename the user for a new host, set `mainUser = "newuser";` in that host's configuration.

### 4.2 Never hardcode `/home/pollux` or `/etc/nixos`

Paths into the dotfiles directory use `config.dotfiles.path`, defaulting to `"/etc/nixos/dotfiles"`. This option is defined in `home-manager.nix` and can be overridden per-host. The actual symlinks are created with `config.lib.file.mkOutOfStoreSymlink` **inside** the Home Manager user module (where `config.lib` is the HM lib, not the NixOS lib).

The path is passed into the HM user module via `home-manager.extraSpecialArgs = { dotfilesPath = config.dotfiles.path; }`.

### 4.3 Cursor — single source of truth is `cursor.nix`

All cursor-related config lives in `modules/features/cursor.nix`. The values `cursorTheme` and `cursorSize` are `let` bindings inside that file. **Do not hardcode cursor strings in any other file.**

Current cursor propagation:
- `environment.sessionVariables` → all sessions (Wayland, X11)
- `programs.dconf` → GTK/GNOME apps
- `environment.etc."xdg/icons/default/index.theme"` → fallback for apps that only read XDG
- `home.pointerCursor` (HM) → HM-managed cursor for GTK apps
- Helium wrapper → `--set XCURSOR_THEME` to fix Chromium-based cursor bug
- Niri config → `cursor.xcursor-theme` in the KDL settings

The `bibataFixed` derivation adds missing cursor symlinks (`hand2`, `sb_v_double_arrow`, `sb_h_double_arrow`) that the upstream `bibata-cursors` package omits.

### 4.4 `perSystem` vs `flake.nixosModules`

Each feature file can define **both**:
- `flake.nixosModules.foo` — the NixOS module (system-level config, services, packages)
- `perSystem` — the package/app build (what `nix run .#foo` uses)

The NixOS module references the built package as `self.packages.${pkgs.stdenv.hostPlatform.system}.foo`.

### 4.5 Nushell wrapper — intentional store-time path coupling

`nushell.nix` bakes `../../dotfiles/nushell/config.nu` into the wrapper as a **fallback** (used only if `~/.config/nushell/config.nu` does not exist). This is intentional: it lets `nix run .#nushell` work on a fresh machine before dotfiles are set up. On a fully configured system, the HM symlink takes precedence.

### 4.6 `nix flake check --no-build` is the linter

Always run this before committing. It catches:
- Syntax errors in any `.nix` file
- Type errors in NixOS option values
- Missing attributes
- Infinite recursion in option definitions

Remaining non-error warnings (harmless):
- `app '...' lacks attribute 'meta.description'` — apps do not need descriptions for functionality
- `aarch64-linux` skipped — only `x86_64-linux` is built locally

---

## 5. The dotfiles system

### 5.1 How it works

Home Manager creates **out-of-store symlinks** from `~/.config/<file>` → `/etc/nixos/dotfiles/<file>`. Because these are out-of-store, you can edit either path and the change is immediate — no rebuild needed.

### 5.2 Add a new config file

```bash
# 1. Move the config into dotfiles/
mkdir -p /etc/nixos/dotfiles/foo
cp ~/.config/foo/config.toml /etc/nixos/dotfiles/foo/config.toml
rm ~/.config/foo/config.toml

# 2. Register it in home-manager.nix — add to the xdg.configFile block:
#      "foo/config.toml".source = link "foo/config.toml";

# 3. Stage, rebuild, commit
git add -A && nr && git commit -m "feat(hm): add foo config"
```

### 5.3 Programs NOT in dotfiles/

Noctalia theming writes to these files dynamically — they are not tracked:
- `btop` colors
- `dconf` / GTK theme selections
- Noctalia's own config

### 5.4 Why some files show as changed in Git

Noctalia writes live color updates to:
- `dotfiles/starship/starship.toml`
- `dotfiles/doom/themes/noctalia-theme.el`

Commit these when you want to persist a new color scheme.

---

## 6. Cursor handling

The cursor has historically been the most bug-prone area. Here is the complete picture:

| Layer | Where set | File |
| :--- | :--- | :--- |
| System env vars | `environment.sessionVariables` | `cursor.nix` |
| GTK/GNOME (dconf) | `programs.dconf.profiles.user` | `cursor.nix` |
| XDG fallback | `/etc/xdg/icons/default/index.theme` | `cursor.nix` |
| Home Manager (GTK) | `home.pointerCursor` | `home-manager.nix` |
| Niri (KDL) | `cursor.xcursor-theme` in settings | `niri.nix` |
| Helium (Chromium) | `--set XCURSOR_THEME` in wrapper | `helium.nix` |

**Why Helium needs special treatment:** Chromium-based browsers ignore system cursor env vars in some Wayland compositors. The wrapper forces the vars at process level and adds `--ozone-platform=wayland` so Helium runs natively on Wayland rather than through XWayland.

**Why `bibataFixed`:** The upstream `bibata-cursors` package is missing several cursor name symlinks. The `bibataFixed` derivation in `cursor.nix` copies the theme and adds them.

---

## 7. Keybindings

### 7.1 Kanata (keyboard layer — runs before Niri)

**Home row mods:**

| Key | Tap | Hold |
| :--- | :--- | :--- |
| A | a | Left Alt |
| S | s | Left Ctrl |
| D | d | Left Super |
| F | f | Left Shift |
| J | j | Right Shift |
| K | k | Right Super |
| L | l | Right Ctrl |
| ; | ; | Right Alt |

Hold time: 200 ms (J and K use 120 ms). Combo window: 35 ms.

**Combos:**

| Keys | Action |
| :--- | :--- |
| U + I | Backspace |
| I + O | Delete |
| N + M | Tab |
| M + , | Browser tab left (Ctrl+PgUp) |
| , + . | Browser tab right (Ctrl+PgDn) |
| Z + X | Undo |
| A + Z | Redo |
| X + C | Copy |
| C + V | Paste |
| X + V | Cut |
| Z + V | Select all |

### 7.2 Niri (window manager)

**Apps:**

| Keys | Action |
| :--- | :--- |
| Mod + Return | Open Ghostty |
| Mod + E | Open Thunar |
| Mod + Shift + E | Open Yazi (in Ghostty) |
| Mod + W | Open Helium |
| Mod + C | Open Emacs client |
| Mod + D | Toggle Noctalia launcher |
| Mod + N | Toggle Noctalia control center |
| Mod + V | Toggle Noctalia clipboard |
| Mod + I | Toggle Noctalia settings |
| Mod + P | Toggle Noctalia session menu |
| Mod + Shift + B | Toggle Noctalia bar |
| Mod + Shift + S | Screenshot area → clipboard |
| Print | Screenshot fullscreen → clipboard |
| Ctrl + Alt + L | Lock screen (hyprlock) |
| Mod + Escape | Lock screen (hyprlock) |

**Windows:**

| Keys | Action |
| :--- | :--- |
| Mod + Q | Close focused window |
| Mod + F | Maximize column |
| Mod + Shift + F | Toggle floating |
| Mod + Shift + C | Center column |
| Mod + R | Cycle column width (33% / 50% / 67% / 100%) |
| Mod + Shift + R | Reset window height |
| Mod + Comma | Consume window into column |
| Mod + Period | Expel window from column |
| Mod + Ctrl + H/L | Shrink/grow column by 5% |

**Focus and movement:**

| Keys | Action |
| :--- | :--- |
| Mod + H / Left | Focus column left |
| Mod + L / Right | Focus column right |
| Mod + J | Focus workspace below |
| Mod + K | Focus workspace above |
| Mod + Shift + H/L | Move column left/right |
| Mod + Shift + J/K | Move column to workspace below/above |
| Mod + 0–9 | Focus workspace w0–w9 |
| Mod + Shift + 0–9 | Move column to workspace w0–w9 |
| Mod + Tab | Toggle overview |
| Mod + Home/End | Focus first/last column |
| Mod + Shift + Home/End | Move column to first/last |

**Media:**

| Keys | Action |
| :--- | :--- |
| XF86MonBrightnessUp/Down | Brightness ±5% |
| XF86AudioRaiseVolume | Volume +2% |
| XF86AudioLowerVolume | Volume −2% |
| XF86AudioMute / Mod+Shift+M | Mute toggle |
| XF86AudioMicMute | Mic mute toggle |
| Mod+Shift+P / XF86AudioPlay | Play/pause |
| Mod+Shift+N / XF86AudioNext | Next track |
| XF86AudioPrev | Previous track |

### 7.3 Doom Emacs

| Keys | Action |
| :--- | :--- |
| SPC r r | Run project |
| SPC p p | Switch project |
| SPC p f | Find file in project |
| SPC f f | Find any file |
| SPC g g | Open Magit |

### 7.4 Shell abbreviations (Nushell)

| Command | Action |
| :--- | :--- |
| `nr` | Rebuild system |
| `nfu` | Update flake inputs |
| `ncd` | `cd /etc/nixos` |
| `z <dir>` | Zoxide jump |
| `ga` | `git add -A` |
| `gc "msg"` | `git commit -m "msg"` |
| `gp` | `git push` |

---

## 8. Daily tasks

### 8.1 Change a system setting

```bash
nvim /etc/nixos/modules/features/foo.nix
nix flake check --no-build          # verify before rebuilding
git add -A && nr
git commit -m "feat(foo): describe change" && git push
```

### 8.2 Change a dotfile config

```bash
# Edit directly — applies immediately for most programs
nvim /etc/nixos/dotfiles/ghostty/config

# Doom Emacs: restart service after Elisp changes
systemctl --user restart emacs.service

# Nushell: requires rebuild
nr
```

### 8.3 Update flake inputs

```bash
nfu
nr
git add flake.lock && git commit -m "chore: update flake inputs" && git push
```

---

## 9. Notes for future agents — bugs fixed, gotchas, rules

> This section records what was learned through debugging so future agents do not repeat the same mistakes.

### 9.1 `lib.file.mkOutOfStoreSymlink` does not exist in NixOS lib

This function only exists in **Home Manager's** `lib`. Inside a HM user module the argument `config` has `config.lib.file.mkOutOfStoreSymlink`. From outside (NixOS level), you cannot call it via `lib.file.*`.

**Fix pattern:**

```nix
home-manager.extraSpecialArgs = { dotfilesPath = config.dotfiles.path; };
home-manager.users.${config.mainUser} = { config, dotfilesPath, ... }: let
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
in { ... };
```

### 9.2 `let` inside an attribute set is invalid Nix syntax

You cannot write `let` in the middle of an attribute set body. Use `config = let ... in { ... };` pattern instead.

### 9.3 Infinite recursion from self-referential option definitions

If a module defines `options.mainUser` and then references `config.users.users` inside that same evaluation chain, you get infinite recursion. `options.mainUser` must be a plain string option with a default — never derived from `config.users`.

### 9.4 `greetd` and `users.users` were hardcoded to `"pollux"`

Both now use `config.mainUser`. The `configuration.nix` module arg includes `config` for this reason.

### 9.5 `wrapper-modules` must follow `nixpkgs`

Without `inputs.nixpkgs.follows = "nixpkgs"` in `flake.nix`, `wrapper-modules` brings its own nixpkgs and causes binary incompatibilities and double nixpkgs evaluation.

### 9.6 Helium cursor bug (Chromium on Wayland)

Chromium-based browsers ignore system `XCURSOR_*` env vars in some compositor configurations. `helium.nix` uses `wrapProgram --set XCURSOR_THEME ...` to force the vars at process level, and adds `--ozone-platform=wayland` for native Wayland rendering.

### 9.7 `bibata-cursors` upstream is missing cursor names

`hand2`, `sb_v_double_arrow`, `sb_h_double_arrow` are absent from the upstream package. The `bibataFixed` derivation in `cursor.nix` adds them as symlinks.

### 9.8 `home.pointerCursor.enable = true` is required

Recent Home Manager versions require explicit `enable = true` on `home.pointerCursor`. Omitting it causes a deprecation warning during evaluation.

### 9.9 Nushell: wrapper fallback vs. HM symlink

On an installed system the HM symlink at `~/.config/nushell/config.nu` takes precedence over the store-baked fallback. On a fresh `nix run .#nushell` session (no dotfiles), the wrapper falls back to the store-baked config. This dual behavior is intentional.

### 9.10 `aarch64-linux` in `systems` but never built locally

This is intentional for future portability. `nix flake check` will warn it is skipped. Harmless.

---

## 10. Run a program without NixOS

```bash
nix run github:McKaigne/dotfiles          # Niri (default)
nix run github:McKaigne/dotfiles#emacs    # Doom Emacs
nix run github:McKaigne/dotfiles#nushell  # Nushell
nix run github:McKaigne/dotfiles#niri     # Niri explicitly
```

---

## 11. Install on a new machine

1. Boot from a NixOS live USB.
2. Partition disks. Mount root at `/mnt`, EFI at `/mnt/boot`.
3. Generate hardware config:
   ```bash
   nixos-generate-config --root /mnt
   ```
4. Clone this repo:
   ```bash
   git clone https://github.com/McKaigne/dotfiles.git /mnt/etc/nixos
   ```
5. Update disk UUIDs in `modules/hosts/castor/hardware.nix` for the new machine.
6. If the username differs, add `mainUser = "newuser";` to the host configuration.
7. Install:
   ```bash
   nixos-install --flake /mnt/etc/nixos#castor
   ```
8. Reboot. Home Manager creates `~/.config` symlinks automatically on first login.

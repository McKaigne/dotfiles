
# Castor — NixOS Workstation

This flake sets up a full NixOS workstation. The workstation uses Niri, Noctalia, Doom Emacs, Nushell, and Kanata.

---

## Table of Contents

1. [Design of this flake](#1-design-of-this-flake)
2. [Software in this workstation](#2-software-in-this-workstation)
3. [File structure](#3-file-structure)
4. [The dotfiles system](#4-the-dotfiles-system)
5. [Keybindings](#5-keybindings)
6. [Daily tasks](#6-daily-tasks)
7. [Run a program without NixOS](#7-run-a-program-without-nixos)
8. [Install on a new machine](#8-install-on-a-new-machine)

---

## 1. Design of this flake

This flake uses three tools together: `flake-parts`, `import-tree`, and `wrapper-modules`.

### 1.1 flake-parts and import-tree

`import-tree` finds every file in the folder `modules/`. `import-tree` adds each file to the flake automatically. You do not need to add new files to `flake.nix`. You only add new files to the folder `modules/`.

### 1.2 wrapper-modules

Some programs run through `wrapper-modules`. This tool builds a program together with its settings. The result is one package. You can run this package on any Linux system. You do not need NixOS to run it.

### 1.3 Home Manager

Home Manager manages the files in `~/.config`. Home Manager reads the folder `dotfiles/`. Home Manager creates a link from `~/.config` to each file in `dotfiles/`.

Section 4 explains this system.

---

## 2. Software in this workstation

| Function | Program |
| :--- | :--- |
| Operating system | NixOS (unstable channel) |
| Window manager | Niri |
| Desktop shell | Noctalia |
| Key remapper | Kanata |
| Text editor | Doom Emacs |
| Shell | Nushell |
| Terminal | Ghostty, Foot |
| File manager | Yazi |
| Web browser | Helium |
| IDE | Antigravity |
| Login manager | Greetd |
| Audio server | PipeWire |
| Font | Maple Mono NF |
| Cursor theme | Bibata Modern Classic |
| Directory jumper | Zoxide |

---

## 3. File structure
```
/etc/nixos/
├── flake.nix # Inputs and outputs for the flake
├── flake.lock # Locked versions of all inputs
├── README.md # This file
├── dotfiles/ # Config files for Home Manager. See section 4.
│ ├── doom/
│ ├── nushell/
│ ├── starship/
│ ├── fuzzel/
│ ├── cava/
│ ├── ghostty/
│ ├── gtk-3.0/
│ ├── gtk-4.0/
│ └── niri/
└── modules/
├── hosts/
│ └── castor/
│ ├── default.nix # Builds the system castor
│ ├── configuration.nix # System settings and module list
│ └── hardware.nix # Disk and CPU settings
└── features/
├── home-manager.nix # Links files from dotfiles/ to ~/.config
├── niri.nix # Niri settings and keybindings
├── noctalia.nix # Noctalia shell settings
├── emacs.nix # Emacs package
├── nushell.nix # Nushell package
├── helium.nix # Helium browser
├── kanata.nix # Key remapper settings
└── desktop.nix # Base tools and Antigravity
```

---

## 4. The dotfiles system

### 4.1 Purpose

The folder `dotfiles/` holds config files for programs. Home Manager reads this folder. Home Manager creates a link in `~/.config` for each file. This makes your config files work on a new machine.

### 4.2 Add a new config file

Do these steps to add a new config file:

1. Make a folder for the program inside `dotfiles/`.
```bash
   mkdir dotfiles/foo
```
2. Put the config file inside this folder.
```bash
   cp ~/.config/foo/config.toml dotfiles/foo/config.toml
```
3. Remove the old config file from `~/.config`.
```bash
   rm ~/.config/foo/config.toml
```
4. Add the new files to Git.
```bash
   git add -A
```
5. Rebuild the system.
```bash
   nr
```

After step 5, Home Manager creates a link from `~/.config/foo/config.toml` to `dotfiles/foo/config.toml`. You can edit this file at either path. Both paths point to the same file.

### 4.3 Programs that are not in dotfiles/

Some programs are not in `dotfiles/`. Noctalia changes the color theme of these programs. Noctalia writes new colors to these files each time you change the theme. These files stay as normal files in `~/.config`. They are not part of this flake.

These programs include:
- btop
- GNOME/KDE theme settings (`dconf`, `kdeglobals`, `qt5ct`, `qt6ct`)
- The Noctalia shell itself

### 4.4 Why some files show as changed in Git

Four files in `dotfiles/` also receive live updates from Noctalia:

- `dotfiles/starship/starship.toml`
- `dotfiles/doom/themes/noctalia-theme.el`
- `dotfiles/fuzzel/themes/noctalia` (not tracked)
- `dotfiles/cava/themes/noctalia` (not tracked)

When you change the Noctalia color theme, Noctalia writes new colors to these files. Git shows these files as changed. This is normal. Commit these changes if you want to keep the new colors. Do not worry if you do not commit them. The files still work.

---

## 5. Keybindings

### 5.1 Kanata (keyboard layer)

Kanata remaps your keyboard. Kanata runs before Niri sees your keypress.

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

Home row mods use a 200 ms hold time. J and K use a 120 ms hold time.

**Combos (35 ms window):**

| Keys | Action |
| :--- | :--- |
| U + I | Backspace |
| I + O | Delete |
| N + M | Tab |
| M + , | Switch browser tab left |
| , + . | Switch browser tab right |
| Z + X | Undo |
| A + Z | Redo |
| X + C | Copy |
| C + V | Paste |
| X + V | Cut |
| Z + V | Select all |

### 5.2 Niri (window manager)

The main modifier key is `Mod`. `Mod` responds to the left Super key and the right Super key equally.

**Windows:**

| Keys | Action |
| :--- | :--- |
| Mod + Q | Close the focused window |
| Mod + F | Maximize the focused column |
| Mod + Shift + F | Toggle floating mode |
| Mod + Shift + C | Center the focused column |
| Mod + R | Change the column width |

**Move focus:**

| Keys | Action |
| :--- | :--- |
| Mod + H / Left | Focus the column on the left |
| Mod + L / Right | Focus the column on the right |
| Mod + J | Go to the workspace below |
| Mod + K | Go to the workspace above |
| Mod + 0-9 | Go to workspace 0-9 |

**Apps:**

| Keys | Action |
| :--- | :--- |
| Mod + Return | Open Ghostty |
| Mod + E | Open Yazi |
| Mod + W | Open Helium |
| Mod + C | Open Emacs |
| Mod + Shift + S | Take a screenshot of an area |

**On startup**, Niri runs three actions:
1. Niri starts Noctalia.
2. Niri sets the wallpaper from `~/Pictures/Wallpapers/wallpaper.jpg`.
3. Niri sets the cursor theme to Bibata Modern Classic.

### 5.3 Doom Emacs

Doom Emacs uses the leader key `SPC`.

| Keys | Action |
| :--- | :--- |
| SPC r r | Run the current project |
| SPC p p | Switch to a different project |
| SPC p f | Find a file in the project |
| SPC f f | Find any file |
| SPC g g | Open Magit |

### 5.4 Shell abbreviations (Nushell)

| Command | Action |
| :--- | :--- |
| `nr` | Rebuild the system |
| `nfu` | Update flake inputs |
| `ncd` | Go to `/etc/nixos` |
| `z <dir>` | Jump to a directory |
| `ga` | `git add -A` |
| `gc "msg"` | `git commit -m "msg"` |
| `gp` | `git push` |

---

## 6. Daily tasks

### 6.1 Change a system setting

Do these steps to change a system setting:

1. Edit a file in `modules/features/`.
2. Add your changes to Git.
```bash
   ga
```
3. Commit your changes.
```bash
   gc "describe your change here"
```
4. Rebuild the system.
```bash
   nr
```
5. Push your changes to GitHub.
```bash
   gp
```

### 6.2 Change a program's config

Do these steps to change a program's config that is in `dotfiles/`:

1. Edit the file inside `dotfiles/`.
2. Your change applies right away. You do not need to rebuild for most programs.
3. Commit and push your changes when you are ready.

Doom Emacs and Nushell need extra steps for some changes:

- For Doom Emacs, restart the Emacs service.
```bash
  systemctl --user restart emacs.service
```
- For Nushell, rebuild the system. Nushell reads its config file at build time.
```bash
  nr
```

---

## 7. Run a program without NixOS

Some programs in this flake build as standalone packages. You can run these packages on any Linux system with Nix installed. You do not need NixOS.

```bash
# Run Niri (the default program)
nix run github:McKaigne/dotfiles

# Run Doom Emacs
nix run github:McKaigne/dotfiles#emacs

# Run Nushell
nix run github:McKaigne/dotfiles#nushell
```

---

## 8. Install on a new machine

Do these steps to install this system on a new machine:

1. Start the machine from a NixOS live USB.
2. Set up your disk partitions. Mount the EFI partition at `/mnt/boot`. Mount the root partition at `/mnt`.
3. Generate a hardware config.
```bash
   nixos-generate-config --root /mnt
```
4. Clone this repository to `/mnt/etc/nixos`.
```bash
   git clone https://github.com/McKaigne/dotfiles.git /mnt/etc/nixos
```
5. Open the file `modules/hosts/castor/hardware.nix`. Update the disk IDs for the new machine.
6. Install the system.
```bash
   nixos-install --flake /mnt/etc/nixos#castor
```
7. Restart the machine.
```bash
   reboot
```

After you restart, Home Manager creates the links in `~/.config` automatically. You do not need extra steps for your dotfiles.

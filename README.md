# nixos

Dendritic, atomic NixOS flake managing two workstations (`castor` and `hyde`), home-manager, Niri scrollable tiling, Noctalia dynamic theme governance, and custom hardware input layers.

## Quick start

```sh
# On workstation Hyde (AMD)
sudo nixos-rebuild switch --flake /etc/nixos#hyde

# On workstation Castor (Intel)
sudo nixos-rebuild switch --flake /etc/nixos#castor
```

Checkout expected at `/etc/nixos`.

## Layout

```text
flake.nix                         inputs + flake-parts + import-tree entrypoint
hosts/
  castor/                         Intel Iris Xe host configuration (pollux)
  hyde/                           AMD GPU + ROCm compute host configuration (jekyll)
modules/
  shared/                         base workstation profile, users, security, audio, core
  features/
    browser/                      Floorp (Sidebery tree tabs + Stylus Osaka), Brave Origin
    desktop/                      Niri compositor, Noctalia v5 shell, fonts, XDG, fuzzel
    terminal/                     Zsh (expanding abbreviations), Ghostty, Tmux (dotbar)
    editor/                       Helix (wrapped LSPs: nixd, marksman, taplo, bash-ls)
    media/                        Cliamp, MPV, Parabolic
    theme/                        Noctalia dynamic GTK 3/4 & Qt 5/6 palette bindings
    creative/                     Blender, Kdenlive, OBS Studio (VAAPI + PipeWire capture)
    documents/                    Obsidian, Zathura, OnlyOffice
    dev/                          Godot 4, hyperfine, tokei, lazydocker
wallpapers/                       Managed desktop background repository
```

## Workstations

| Host | User | Graphics & Acceleration | Kernel & Storage Tuning | Role |
| :--- | :--- | :--- | :--- | :--- |
| **hyde** | `jekyll` | AMD Radeon (`amdgpu`) + ROCm / HIP compute | Kingston NV2 APST fix (`nvme_core.default_ps_max_latency_us=0`), `pcie_aspm=off`, zram | Main workstation / 3D & Compute |
| **castor** | `pollux` | Intel Iris Xe (`iHD` / `intel-media-driver`) | Framebuffer compression (`i915.enable_fbc=1`), aggressive zram swappiness (180), thermald | Secondary workstation / Mobile |

Both hosts share the unified `baseWorkstation` profile while isolating hardware runtimes and state versions.

## Core Stack

| Component | Implementation | Notes |
| :--- | :--- | :--- |
| **Compositor** | [niri](https://github.com/YaLTeR/niri) | Scrollable tiling, 4px geometry corners, GPU blur, 240Hz DP-1 output |
| **Desktop Shell** | [noctalia](https://github.com/noctalia-dev/noctalia) | Floating top bar, dynamic templates, Solarized Osaka palette authority |
| **Display Manager** | [greetd](https://git.sr.ht/~kennylevinsen/greetd) | Auto-launches wrapped `niri-session` via PAM |
| **Shell** | [zsh](https://www.zsh.org/) | Pure POSIX, zero aliases, native ZLE inline-expanding abbreviations, Starship |
| **Terminal** | [ghostty](https://ghostty.org/) | Native Wayland, Lilex Nerd Font with OpenType features, 14px thickened |
| **Multiplexer** | [tmux](https://github.com/tmux/tmux) | Custom Osaka "dotbar", popup file explorer (`nnn`), FZF session switchers |
| **Editor** | [helix](https://helix-editor.com/) | Hermetically wrapped with LSPs (`nixd`, `marksman`, `taplo`, `shfmt`) |
| **Browsers** | [floorp](https://floorp.app/) + [brave](https://brave.com/) | Floorp: Sidebery tree tabs + Stylus Osaka; Brave Origin: isolated fallback |
| **Keymap Engine** | [kanata](https://github.com/jtroo/kanata) | Layerless Programmer QWERTY, Timeless Home-Row Mods (ACGS), Combos |
| **Audio** | [pipewire](https://pipewire.org/) | WirePlumber + EasyEffects daemon integration |

## Theming Architecture

Desktop theming is governed strictly by **Noctalia**. Applications do not hardcode static hex palettes; they consume generated `noctalia` tokens:
* **GTK 3 & GTK 4:** `@import 'noctalia.css';` dynamically emitted by Noctalia.
* **Qt 5 & Qt 6:** Pointed to `~/.config/qt6ct/colors/noctalia.conf`.
* **Ghostty & Helix:** Configured with `theme = noctalia`, populated by Noctalia's built-in template engine.
* **Tmux & Sidebery:** Aligned with Noctalia's active Solarized Osaka palette (`#00141a` base, `#073642` surface, `#2aa198` Osaka Cyan accent).
* **Typography:** **IBM Plex Sans** for interface chrome paired with **Lilex Nerd Font** for monospace buffers, backed by FreeType subpixel RGB LCD filtering.

## Keyboard Architecture (Kanata)

The keyboard layer is completely layerless, built on **Programmer QWERTY ANSI** with hardware-intercepted chords:

### 1. Programmer QWERTY Inversions
* **Number Row:** Unshifted outputs symbols (`+ [ { ( & = ) } ] * ! $`); Shifted outputs digits (`1 2 3 4 5 6 7 8 9 0 %`).
* **Brackets & Backslash:** `[` outputs `-` / `_`; `]` outputs `@` / `^`; `\` outputs `\` / `#`.
* **Caps Lock:** Remapped to `Escape`.

### 2. Timeless Home-Row Mods (ACGS Order)
Home-row keys use `tap-hold-release` (200ms tap / 250ms hold) to eliminate index-finger rolling misfires:
* **Left Hand:** `a` (Alt) • `s` (Ctrl) • `d` (GUI) • `f` (Shift)
* **Right Hand:** `j` (Shift) • `k` (GUI) • `l` (Ctrl) • `;` (Alt)

### 3. Hardware Chords (50ms Threshold)
* `Z + X` → Cut (`Shift + Delete`)
* `X + C` → Copy (`Ctrl + Insert`)
* `C + V` → Paste (`Shift + Insert`)
* `V + B` → Select All (`Ctrl + A`)
* `F + J` → CapsWord (`caps-word 2000`)
* `J + K` → Delete Word Backward (`Ctrl + Backspace`)
* `D + F` → Tmux Prefix (`Ctrl + B`)
* `N + M` → Redo (`Ctrl + Y`)
* `M + ,` → Undo (`Ctrl + Z`)
* `, + .` → Find (`Ctrl + F`)

## Multiplexer Binds (Tmux Dotbar)

Tmux runs with a Solarized Osaka dotbar (`●` active, `○` inactive) and un-prefixed `Alt` bindings:

| Keybinding | Action |
| :--- | :--- |
| `Alt + h/j/k/l` | Navigate panes left / down / up / right |
| `Alt + 1-9, 0` | Focus window 1–10 (auto-creates window if non-existent) |
| `Alt + H / L` | Previous / Next window |
| `Alt + J / K` | Previous / Next session |
| `Alt + n` / `Alt + v` | Horizontal split / Vertical split |
| `Alt + x` / `Alt + X` | Kill active pane / Kill active window |
| `Alt + c` | Create new window |
| `Alt + ,` / `Alt + $` | Rename active window / Rename active session |
| `Alt + e` | Floating file explorer popup (`nnn`) |
| `Alt + t` | Floating system monitor popup (`btop`) |
| `Alt + z` / `Alt + f` | Toggle pane zoom / fullscreen |
| `Alt + Arrows` | Resize pane (repeatable / holdable) |
| `Alt + m` / `Alt + b` | Mark pane / Join marked pane |
| `Prefix + C-j` | Interactive FZF session switcher |
| `Prefix + C-k` | Interactive FZF window switcher |
| `Prefix + C-v` | Interactive FZF running editor switcher (`hx`, `nvim`, `vim`) |
| `Prefix + Alt-4` | Select `main-vertical` layout (1 primary pane + vertical stack) |
| `Alt + O` | Cycle panes inside `main-vertical` layout |

## Inputs

* `nixpkgs` (`nixos-unstable`)
* `home-manager`
* `flake-parts`
* `import-tree`
* `noctalia`
* `cliamp`
* `wrapper-modules`

# Dendritic NixOS Workstations: Castor & Hyde

An atomic, dendritic NixOS configuration managing two specialized workstations (`castor` and `hyde`), scrollable tiling with Niri, Noctalia dynamic theme authority, layerless Programmer QWERTY hardware input interception, and an editor-multiplexer workflow.

---

## Quick Start

```sh
# On workstation Hyde (AMD Compute Workstation)
sudo nixos-rebuild switch --flake /etc/nixos#hyde

# On workstation Castor (Intel Mobile Workstation)
sudo nixos-rebuild switch --flake /etc/nixos#castor
```

Checkout path expected at `/etc/nixos`.

---

## Topology & Workstation Roles

| Host | Primary User | Graphics & Acceleration | Kernel & Memory Tuning | Workstation Role |
| :--- | :--- | :--- | :--- | :--- |
| **hyde** | `jekyll` | AMD Radeon (`amdgpu`) + ROCm / HIP compute (`rocmPackages.clr.icd`) | Kingston NV2 APST fix (`nvme_core.default_ps_max_latency_us=0`), `pcie_aspm=off`, low swappiness (`vm.swappiness = 10`) | Main workstation: 3D Blender Cycles rendering, compute & dev |
| **castor** | `pollux` | Intel Iris Xe (`intel-media-driver` / `iHD`) | Framebuffer compression (`i915.enable_fbc=1`), aggressive zram swappiness (`180`), thermald | Secondary workstation: Lightweight, mobile efficiency & media |

Both hosts share the unified `baseWorkstation` profile while isolating hardware runtimes and user environments.

---

## Repository Layout (Single-Responsibility Architecture)

Every component is an isolated directory with its own dedicated `default.nix` entrypoint and co-located configuration assets:

```text
/etc/nixos
├── flake.nix                         # Inputs, outputs, and import-tree root
├── README.md                         # Architectural specification & guide
├── wallpapers/                       # System desktop background repository
└── modules/
    ├── hosts/
    │   ├── castor/                   # Intel host profile & drive UUIDs
    │   └── hyde/                     # AMD host profile & drive UUIDs
    ├── shared/                       # Shared workstation infrastructure
    │   ├── audio/                    # PipeWire, WirePlumber, RTKit, firmwares
    │   ├── base/                     # baseWorkstation profile uniting modular units
    │   ├── bluetooth/                # BlueZ, Blueman, Lofree Flow udev rules
    │   ├── core/                     # Nix daemon, Cachix, system packages
    │   ├── kanata/                   # Programmer QWERTY, ACGS home-row mods, chords
    │   ├── security/                 # Polkit agent, GNOME Keyring, SOPS, age
    │   ├── systems/                  # Systems matrix, formatter, CI check derivations
    │   └── users/                    # mainUser option, Home Manager integration
    └── features/                     # Decoupled application modules
        ├── browser/
        │   ├── brave/                # Brave Origin + policies + out-of-store link
        │   └── floorp/               # Floorp browser + Sidebery + Tridactyl native
        ├── creative/
        │   ├── blender/              # Blender 3D modeling
        │   ├── kdenlive/             # Kdenlive video editor & MLT framework
        │   ├── krita/                # Krita digital raster graphics
        │   └── obs/                  # OBS Studio + VAAPI + PipeWire capture
        ├── desktop/
        │   ├── fonts/                # Lilex Nerd Font, IBM Plex, subpixel rendering
        │   ├── fuzzel/               # Fuzzel launcher + Noctalia theme import
        │   ├── niri/                 # Niri compositor wrapper & niri.kdl asset
        │   ├── noctalia/             # Desktop shell daemon & noctalia.toml asset
        │   └── xdg/                  # PCManFM, portals, MIME associations
        ├── dev/
        │   ├── git/                  # Git user credentials & defaults
        │   ├── godot/                # Godot 4 game engine
        │   └── tools/                # lazydocker, tokei, hyperfine, glow
        ├── documents/
        │   ├── obsidian/             # Obsidian markdown knowledge base
        │   ├── onlyoffice/           # OnlyOffice desktop editors suite
        │   └── zathura/              # Zathura document viewer (Noctalia styled)
        ├── editor/
        │   └── helix/                # Wrapped Helix + LSPs + Osaka transparent theme
        ├── media/
        │   ├── imv/                  # Imv image viewer
        │   ├── mpv/                  # MPV video player (gpu-next, wayland)
        │   └── parabolic/            # Parabolic media downloader
        ├── network/
        │   └── localsend/            # LocalSend daemon + port 53317 firewall
        ├── security/
        │   └── bitwarden/            # Bitwarden desktop client
        ├── terminal/
        │   ├── fetch/                # areofyl/fetch 3D rotating ASCII engine
        │   ├── ghostty/              # Ghostty terminal + Lilex OpenType features
        │   ├── starship/             # Starship prompt derivation & starship.toml
        │   ├── tmux/                 # Tmux multiplexer + non-colliding keymaps
        │   └── zsh/                  # Zsh + expanding abbreviations + cfb tool
        └── theme/
            └── noctalia/             # GTK 3/4 & Qt 5/6 dynamic stylesheet bindings
```

---

## Core Stack & Ergonomics

| Subsystem | Implementation | Key Operational Notes |
| :--- | :--- | :--- |
| **Compositor** | [niri](https://github.com/YaLTeR/niri) | Scrollable tiling, geometry corners 4px, GPU blur, 240Hz DP-1 display |
| **Desktop Shell** | [noctalia](https://github.com/noctalia-dev/noctalia) | Dynamic template engine, floating top bar, binary substituted via Cachix |
| **Display Manager** | [greetd](https://git.sr.ht/~kennylevinsen/greetd) | Auto-launches wrapped `niri-session` via PAM |
| **Shell** | [zsh](https://www.zsh.org/) | Pure POSIX, zero aliases, native ZLE expanding abbreviations, Starship |
| **Terminal** | [ghostty](https://ghostty.org/) | Native Wayland, Lilex Nerd Font with OpenType features (`cv01`, `ss01`), 0.85 blur |
| **Multiplexer** | [tmux](https://github.com/tmux/tmux) | Custom Osaka dotbar, OSC 52 clipboard, floating tool popups over editor |
| **Editor** | [helix](https://helix-editor.com/) | Wrapped with LSPs (`nixd`, `marksman`, `taplo`), transparent Osaka palette |
| **Telemetry** | [fetch](https://github.com/areofyl/fetch) | 3D spinning ASCII distro engine with Blinn-Phong shading and live metrics |
| **Keyboard Engine** | [kanata](https://github.com/jtroo/kanata) | Layerless Programmer QWERTY, Timeless Home-Row Mods (ACGS), Bottom Chords |

---

## Theming Governance (Noctalia Authority)

Desktop styling is governed dynamically by **Noctalia**. Downstream tools do not hardcode static color values in Nix code:
* **GTK 3 & GTK 4:** `@import 'noctalia.css';` dynamically emitted by Noctalia.
* **Qt 5 & Qt 6:** Pointed to `~/.config/qt6ct/colors/noctalia.conf`.
* **Ghostty & Tmux:** Configured with user templates rendered dynamically by Noctalia on theme or wallpaper switch.
* **Fuzzel:** Imports `~/.config/fuzzel/themes/noctalia` generated via community template.
* **Helix:** Configured with a dedicated transparent Solarized Osaka theme (`ui.background = {}`) using the complete 8-accent chromatic palette to preserve syntax discrimination.

---

## Keyboard Architecture (Kanata)

The keyboard layer runs entirely in software via Kanata v1.12.0 using **Programmer QWERTY ANSI**:

### 1. Inverted Number Row
* **Unshifted:** Outputs symbols (`+ [ { ( & = ) } ] * ! $`).
* **Shifted:** Outputs digits (`1 2 3 4 5 6 7 8 9 0 %`).
* **Caps Lock:** Remapped to `Escape`.

### 2. Timeless Home-Row Mods (ACGS Order)
Uses native `defhands` bilateral isolation (`tap-hold-opposite-hand-release`) and `tap-hold-require-prior-idle 120`:
* **Left Hand:** `a` (Alt) • `s` (Ctrl) • `d` (GUI) • `f` (Shift)
* **Right Hand:** `j` (Shift) • `k` (GUI) • `l` (Ctrl) • `;` (Alt)

### 3. Hardware Chords (`defchordsv2`)
* `Z + X` → Cut (`Shift + Delete`)
* `X + C` → Copy (`Ctrl + Insert`)
* `C + V` → Paste (`Shift + Insert`)
* `V + B` → Select All (`Ctrl + A`)
* `N + M` → Redo (`Ctrl + Y`)
* `M + ,` → Undo (`Ctrl + Z`)
* `, + .` → Find (`Ctrl + F`)

---

## Editor & Multiplexer Symbiosis (Helix + Tmux)

To prevent multiplexer key collisions while inside Helix:
* **Unprefixed `Alt` Keys:** Reserved strictly for high-frequency window and pane navigation:
  * `Alt + h/j/k/l`: Move pane left, down, up, right
  * `Alt + 1-9, 0`: Switch to window 1–10 (auto-creates if non-existent)
  * `Alt + H / L`: Previous / Next window
  * `Alt + J / K`: Previous / Next session
* **Prefix (`Ctrl+b`) Keys:** Manages splits, windows, and floating overlay tools:
  * `Prefix + c`: New window
  * `Prefix + -` / `Prefix + |`: Horizontal / Vertical split
  * `Prefix + x`: Kill active pane
  * `Prefix + g`: Floating `lazygit` popup centered over active pane
  * `Prefix + t`: Floating `btop` system monitor popup
  * `Prefix + p`: Floating scratchpad terminal popup
  * `Prefix + C-v`: Interactive FZF picker across all running Helix panes
* Inside Helix, `Alt+x` (shrink selection), `Alt+c` (copy selection below), and `Alt+n` (next AST sibling) execute without Tmux interference.
* Terminal focus events (`focus-events on`) automatically trigger Helix buffer auto-saving on pane switch.

---

## Adapting This Configuration for New Users

1. **Host & User Configuration:**
   * Update `mainUser` in `modules/hosts/<host>/default.nix` (e.g., `mainUser = "yourname";`).
   * Rename `modules/hosts/hyde` or `castor` to your desired hostname.
2. **Hardware & Filesystems:**
   * Generate your hardware config with `nixos-generate-config --show-hardware-config`.
   * Update the drive UUIDs inside `modules/hosts/<host>/hardware.nix`.
3. **Flake Metadata:**
   * Run `nix flake check` to verify system evaluation.
   * Switch with `sudo nixos-rebuild switch --flake /etc/nixos#<host>`.

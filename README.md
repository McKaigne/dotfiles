# Dendritic NixOS Workstations: Castor & Hyde

An atomic, dendritic NixOS configuration managing two specialized workstations (`castor` and `hyde`), scrollable tiling with Niri, Noctalia dynamic theme authority, layerless Programmer QWERTY hardware input interception, and an editor-multiplexer workflow.

---

## Quick Start

~~~sh
# On workstation Hyde (AMD Compute Workstation)
sudo nixos-rebuild switch --flake /etc/nixos#hyde

# On workstation Castor (Intel Mobile Workstation)
sudo nixos-rebuild switch --flake /etc/nixos#castor
~~~

Checkout path expected at `/etc/nixos`.

---

## Topology & Workstation Roles

| Host | Primary User | Graphics & Acceleration | Kernel, Storage & Memory Tuning | Workstation Role |
| :--- | :--- | :--- | :--- | :--- |
| **hyde** | `jekyll` | AMD Radeon (`amdgpu`) + declarative OpenCL (`hardware.amdgpu.opencl.enable`) + cached HIP Cycles compute (`pkgs.pkgsRocm.blender`) | Kingston NV2 APST fix (`nvme_core.default_ps_max_latency_us=0`), `pcie_aspm=off`, deterministic device timeout (`systemd.default_device_timeout_sec=30`), root ext4 flags (`noatime,nodiratime,commit=60`), low swappiness (`vm.swappiness = 10`) | Main workstation: 3D Blender Cycles rendering, compute & dev |
| **castor** | `pollux` | Intel Iris Xe (`intel-media-driver` / `iHD`) | Framebuffer compression (`i915.enable_fbc=1`), aggressive zram swappiness (`180`), root ext4 flags (`noatime,nodiratime,commit=60`), thermald | Secondary workstation: Lightweight, mobile efficiency & media |

Both hosts share the unified `baseWorkstation` profile while isolating hardware runtimes and user environments.

---

## Repository Layout (Single-Responsibility Architecture)

Every component is an isolated directory with its own dedicated `default.nix` entrypoint and co-located configuration assets:

~~~text
/etc/nixos
├── flake.nix                         # Inputs, outputs, and import-tree root
├── README.md                         # Architectural specification & guide
├── wallpapers/                       # System desktop background repository
└── modules/
    ├── hosts/
    │   ├── castor/                   # Intel host profile & drive UUIDs
    │   └── hyde/                     # AMD host profile, OpenCL & drive UUIDs
    ├── shared/                       # Shared workstation infrastructure
    │   ├── audio/                    # PipeWire, WirePlumber, RTKit, firmwares
    │   ├── base/                     # baseWorkstation profile uniting modular units
    │   ├── bluetooth/                # BlueZ, Blueman, Lofree Flow udev rules
    │   ├── core/                     # Nix daemon, Cachix, system packages, unfree allowed
    │   ├── kanata/                   # Programmer QWERTY, ACGS home-row mods (150ms idle), chords
    │   ├── security/                 # Polkit agent, GNOME Keyring, SOPS, age
    │   ├── systems/                  # Systems matrix, RFC 166 formatter, CI check derivations
    │   └── users/                    # mainUser option, Home Manager integration
    └── features/                     # Decoupled application modules
        ├── browser/
        │   ├── brave/                # Brave Origin + enterprise policies + Quad9 DoH
        │   └── floorp/               # Floorp (release channel locked) + Sidebery + Tridactyl native
        ├── creative/
        │   ├── blender/              # Blender with cached ROCm/HIP Cycles GPU acceleration
        │   ├── kdenlive/             # Kdenlive video editor & MLT framework
        │   ├── krita/                # Krita digital raster graphics
        │   └── obs/                  # OBS Studio + VAAPI + native PipeWire audio/video capture
        ├── desktop/
        │   ├── fonts/                # Lilex Nerd Font, IBM Plex, subpixel rendering
        │   ├── fuzzel/               # Fuzzel launcher + Noctalia theme import
        │   ├── niri/                 # Niri compositor wrapper, 240Hz 2-pass blur & niri.kdl asset
        │   ├── noctalia/             # Desktop shell daemon & noctalia.toml asset
        │   └── xdg/                  # PCManFM, portals, MIME associations
        ├── dev/
        │   ├── containers/           # Rootless Podman & active Docker socket emulation
        │   ├── git/                  # Git user credentials & defaults
        │   ├── godot/                # Godot 4 game engine
        │   └── tools/                # lazydocker, tokei, hyperfine, ast-grep, ghgrab
        ├── documents/
        │   ├── obsidian/             # Obsidian markdown knowledge base (unfree permitted)
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
        │   ├── starship/             # Starship prompt derivation & /etc/starship.toml authority
        │   ├── tmux/                 # Tmux multiplexer + non-colliding keymaps
        │   └── zsh/                  # Zsh + expanding abbreviations + cfb context tool
        └── theme/
            └── noctalia/             # Declarative GTK 3/4 & Qt 5/6 dynamic stylesheet bindings
~~~

---

## Core Stack & Ergonomics

| Subsystem | Implementation | Key Operational Notes |
| :--- | :--- | :--- |
| **Compositor** | [niri](https://github.com/YaLTeR/niri) | Scrollable tiling, geometry corners 4px, 2-pass GPU blur tuned for 240Hz DP-1, systemd-first session launch |
| **Desktop Shell** | [noctalia](https://github.com/noctalia-dev/noctalia) | Dynamic template engine, floating top bar, wallpaper layer-shell authority, binary substituted via Cachix |
| **Containers** | [podman](https://podman.io/) | Daemonless, rootless containers with active `dockerSocket.enable` powering `lazydocker` via `/run/podman/podman.sock` |
| **Web Browsers** | [floorp](https://floorp.app/) & [brave](https://brave.com/) | Floorp locked to `"release"` channel with experimental progressive rollouts disabled; Tridactyl native messaging; Quad9 DoH |
| **Render Compute** | [blender](https://www.blender.org/) | Pre-built cached HIP Cycles GPU rendering on AMD via `pkgs.pkgsRocm.blender` without local LLVM source compilations |
| **Code Refactoring** | [ast-grep](https://ast-grep.github.io/) | Tree-sitter syntax-aware code search and rewriting (`sg`) |
| **Telemetry** | [fetch](https://github.com/areofyl/fetch) | 3D spinning ASCII distro engine with Blinn-Phong shading and live metrics |
| **Pipelining** | [viddy](https://github.com/sachaos/viddy) + [choose](https://github.com/theryangeary/choose) | Time-travel diff watcher replacing `watch`; ergonomic field slicer replacing `cut` |
| **Editor** | [helix](https://helix-editor.com/) | Wrapped with LSPs (`nixd`, `marksman`, `taplo`), RFC 166 `nixfmt`, transparent Osaka palette |
| **Multiplexer** | [tmux](https://github.com/tmux/tmux) | Custom Osaka dotbar, OSC 52 clipboard, floating tool popups over editor with empty-safe xargs |
| **Keyboard Engine** | [kanata](https://github.com/jtroo/kanata) | Layerless Programmer QWERTY, Timeless Home-Row Mods (ACGS) with harmonized 150ms idle timings, Bottom Chords |
| **Shell Prompt** | [starship](https://starship.rs/) | Declarative system-level authority at `/etc/starship.toml` ensuring universal prompt metrics across shells |

---

## Theming Governance (Noctalia Authority)

Desktop styling is governed dynamically by **Noctalia**. Downstream tools do not hardcode static color values in Nix code:
* **GTK 3 & GTK 4:** `@import 'noctalia.css';` dynamically emitted by Noctalia.
* **Qt 5 & Qt 6:** Declaratively bridged via `qt.platformTheme = "qt5ct"` pointing to `~/.config/qt6ct/colors/noctalia.conf` and `~/.config/qt5ct/colors/noctalia.conf`.
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
Uses native `defhands` bilateral isolation (`tap-hold-opposite-hand-release`) and harmonized `require-prior-idle 150`:
* **Left Hand:** `a` (Alt) • `s` (Ctrl) • `d` (GUI) • `f` (Shift)
* **Right Hand:** `j` (Shift) • `k` (GUI) • `l` (Ctrl) • `;` (Alt)

### 3. Hardware Chords (`defchordsv2`)
* `Z + X` → Cut (`Shift + Delete`)
* `X + C` → Copy (`Ctrl + Insert`)
* `C + V` → Paste (`Shift + Insert`)
* `V + B` → Select All (`Ctrl + A`)
* `F + J` → Caps Word (2000ms timeout)
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

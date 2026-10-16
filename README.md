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

| Host | Primary User | Graphics & Compute Stack | Storage, Kernel & Memory Invariants | Workstation Role |
| :--- | :--- | :--- | :--- | :--- |
| **hyde** | `jekyll` | AMD Radeon (`amdgpu`) + declarative OpenCL (`hardware.amdgpu.opencl.enable`) + pre-built HIP Cycles compute (`pkgs.pkgsRocm.blender`) | Kingston NV2 APST fix (`nvme_core.default_ps_max_latency_us=0`), `pcie_aspm=off`, deterministic device timeout (`systemd.default_device_timeout_sec=30`), root ext4 flags (`noatime,commit=60`), pure ZRAM swappiness (`vm.swappiness = 180`) | Main workstation: 3D Blender Cycles rendering, compute & dev |
| **castor** | `pollux` | Intel Iris Xe (`intel-media-driver` / `iHD`) | Framebuffer compression (`i915.enable_fbc=1`), aggressive zram swappiness (`180`), root ext4 flags (`noatime,commit=60`), thermald | Secondary workstation: Lightweight, mobile efficiency & media |

Both hosts share the unified `baseWorkstation` profile while isolating hardware runtimes and user environments.

---

## Agent & LLM Operational Guardrails (Do Not Violate)

When an automated agent or LLM reasons over this configuration (via `cfb` snapshots), the following invariants must be strictly respected:

1. **Starship Configuration Authority**:
   * Starship is managed strictly at `/etc/starship.toml` via `environment.etc` and `environment.sessionVariables.STARSHIP_CONFIG = "/etc/starship.toml"`.
   * **Do not** refactor Starship into Home Manager user templates or attempt to make it dynamic via Noctalia hooks.
2. **Niri Layer-Shell & Wallpaper Invariant**:
   * Desktop wallpapers are rendered directly by Noctalia on the standard Wayland background layer (`Layer::Background`).
   * **Do not** add `noctalia-wallpaper` or Noctalia wallpaper namespaces to `place-within-backdrop true` in `niri.kdl`.
3. **Compute & Binary Cache Invariants**:
   * Host `hyde` uses `pkgs.pkgsRocm.blender` and `hardware.amdgpu.opencl.enable`.
   * **Do not** add un-cached ROCm packages or `rocmPackages.clr.icd` directly.
4. **Flake Architecture Memoization**:
   * In `modules/shared/systems/default.nix`, consume `inputs.nixpkgs.legacyPackages.${system}`.
   * **Do not** call `import inputs.nixpkgs { ... }` inside `perSystem`.

---

## Repository Layout (Single-Responsibility Architecture)

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
        │   ├── brave/                # Brave Origin + policies + Quad9 DoH
        │   └── librewolf/            # LibreWolf + Sidebery vertical trees + Tridactyl native
        ├── creative/
        │   ├── blender/              # Blender with cached ROCm/HIP Cycles GPU acceleration
        │   ├── kdenlive/             # Kdenlive video editor & MLT framework
        │   ├── krita/                # Krita digital raster graphics
        │   └── obs/                  # OBS Studio + VAAPI + native PipeWire audio capture
        ├── desktop/
        │   ├── fonts/                # Lilex Nerd Font, IBM Plex, subpixel rendering
        │   ├── fuzzel/               # Fuzzel launcher + Catppuccin Mocha theme
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
        │   └── zathura/              # Zathura document viewer (Catppuccin styled)
        ├── editor/
        │   └── helix/                # Wrapped Helix + LSPs + Catppuccin transparent theme
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
        │   ├── tmux/                 # Tmux multiplexer + dotbar Catppuccin theme
        │   └── zsh/                  # Zsh + expanding abbreviations + cfb context tool
        └── theme/
            └── catppuccin/           # Declarative GTK 3/4 & Qt 5/6 Catppuccin Mocha styling
~~~

---

## Core Stack & Ergonomics

| Subsystem | Implementation | Key Operational Notes |
| :--- | :--- | :--- |
| **Compositor** | [niri](https://github.com/YaLTeR/niri) | Scrollable tiling, geometry corners 4px, 2-pass GPU blur tuned for 240Hz DP-1, systemd-first session launch |
| **Desktop Shell** | [noctalia](https://github.com/noctalia-dev/noctalia) | Static template authority, floating top bar, wallpaper layer-shell authority, binary substituted via Cachix |
| **Containers** | [podman](https://podman.io/) | Daemonless, rootless containers with active `dockerSocket.enable` powering `lazydocker` via `/run/podman/podman.sock` |
| **Web Browsers** | [librewolf](https://librewolf.net/) & [brave](https://brave.com/) | LibreWolf with container persistence, Sidebery vertical trees, Tridactyl native messaging; Quad9 DoH |
| **Render Compute** | [blender](https://www.blender.org/) | Pre-built cached HIP Cycles GPU rendering on AMD via `pkgs.pkgsRocm.blender` without local LLVM compilations |
| **Code Refactoring** | [ast-grep](https://ast-grep.github.io/) | Tree-sitter syntax-aware code search and rewriting (`sg`) |
| **Telemetry** | [fetch](https://github.com/areofyl/fetch) | 3D spinning ASCII distro engine with Blinn-Phong shading and live metrics |
| **Pipelining** | [viddy](https://github.com/sachaos/viddy) + [choose](https://github.com/theryangeary/choose) | Time-travel diff watcher replacing `watch`; ergonomic field slicer replacing `cut` |
| **Editor** | [helix](https://helix-editor.com/) | Wrapped with LSPs (`nixd`, `marksman`, `taplo`), RFC 166 `nixfmt`, transparent Catppuccin palette |
| **Multiplexer** | [tmux](https://github.com/tmux/tmux) | Dotbar with Catppuccin borders, OSC 52 clipboard, floating tool popups over editor with empty-safe xargs |
| **Keyboard Engine** | [kanata](https://github.com/jtroo/kanata) | Layerless Programmer QWERTY, Timeless Home-Row Mods (ACGS) with harmonized 150ms idle timings, Bottom Chords |
| **Shell Prompt** | [starship](https://starship.rs/) | System-level authority at `/etc/starship.toml` ensuring universal prompt metrics across all shells |

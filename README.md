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

---

## Agent & LLM Operational Guardrails (Do Not Violate)

When an automated agent or LLM reasons over this configuration (via `cfb` snapshots), the following invariants must be strictly respected:

1. **Starship Configuration Authority**:
   * Starship is managed strictly at `/etc/starship.toml` via `environment.etc` and `environment.sessionVariables.STARSHIP_CONFIG = "/etc/starship.toml"`.
2. **Niri Layer-Shell & Wallpaper Invariant**:
   * Desktop wallpapers are rendered directly by Noctalia on the standard Wayland background layer (`Layer::Background`).
   * Noctalia's backdrop is mapped exclusively via `layer-rule { match namespace="^noctalia-backdrop$" place-within-backdrop true; }`.
3. **Compute & Binary Cache Invariants**:
   * Host `hyde` uses `pkgs.pkgsRocm.blender` and `hardware.amdgpu.opencl.enable`. Do not add un-cached ROCm derivations.
4. **Pure ZRAM Invariant**:
   * Never set `vm.swappiness = 10` on pure ZRAM (`swapDevices = [ ]`). Enforce `180`.

---

## Keybinding Taxonomy (Spatial Hemispheric Split)

### Left Hand: Core Engines & Applications
* **`Mod + Space`**: Switch focus between floating and tiling layers
* **`Mod + Shift + Space`**: Toggle current window between floating and tiled
* **`Mod + A`**: Launch Noctalia App Runner • **`Shift`**: Niri Workspace Overview • **`Ctrl`**: Noctalia Control Center
* **`Mod + S`**: Focus/Raise LibreWolf • **`Shift`**: Toggle Floating LibreWolf • **`Ctrl`**: Force New Tiled LibreWolf • **`Alt`**: Private Window
* **`Mod + D`**: Focus/Raise Ghostty • **`Shift`**: Toggle Floating Scratchpad • **`Ctrl`**: Force New Tiled Ghostty • **`Alt`**: Tmux Project Sessionizer
* **`Mod + F`**: Focus/Raise PCManFM • **`Shift`**: Toggle Floating PCManFM • **`Ctrl`**: Force New Tiled PCManFM
* **`Mod + G`**: Notification Center • **`Shift`**: Dismiss Notice • **`Ctrl`**: Toggle Top Bar
* **`Mod + Z`**: Focus/Raise ZenNotes • **`Shift`**: Toggle Floating ZenNotes • **`Ctrl`**: Force New Tiled ZenNotes
* **`Mod + X`**: Focus/Raise `nnn` Helix Dashboard • **`Shift`**: Toggle Floating `nnn` • **`Ctrl`**: Force New Tiled `nnn`
* **`Mod + C`**: Universal Copy (`Ctrl+Insert`) • **`Shift`**: Universal Cut (`Shift+Delete`)
* **`Mod + V`**: Universal Paste (`Shift+Insert`) • **`Shift`**: Noctalia Clipboard History Panel
* **`Mod + B`**: Bluetooth Manager • **`Shift`**: Bitwarden Desktop
* **`Mod + Q`**: Close Window • **`Mod + W`**: Wallpaper Panel • **`Mod + E`**: Audio Pavucontrol • **`Mod + Shift + E`**: EasyEffects DSP
* **`Mod + R`**: Area Snip to Clipboard • **`Mod + Shift + R`**: Fullscreen Screenshot • **`Mod + T`**: Noctalia Settings GUI

### Right Hand: Navigation & Ribbon Geometry
* **`Mod + H / L`**: Focus Column Left / Right • **`Shift`**: Move Column Left / Right
* **`Mod + J / K`**: Focus Workspace Down / Up • **`Shift`**: Move Column Down / Up
* **`Mod + N / M`**: Focus Window Down / Up (inside column) • **`Shift`**: Move Window Down / Up
* **`Mod + U / I`**: Column Ingestion: Consume / Expel Left / Right
* **`Mod + Y / O`**: Column Width: Shrink / Expand Width (`-5%` / `+5%`)
* **`Mod + Shift + Y / O`**: Window Height: Shrink / Expand Height (`-5%` / `+5%`)
* **`Mod + P`**: Power/Session Menu • **`Shift`**: Lock Screen • **`Ctrl`**: Turn Off Displays
* **`Mod + , / .`**: Focus Monitor Left / Right • **`Shift`**: Move Column to Monitor L / R
* **`Mod + Return`**: Maximize Column Width • **`Shift`**: Fullscreen Window
* **`Mod + /`**: Catppuccin Mocha Fuzzel Interactive Keybind Cheat Sheet
* **`Mod + 1..9`**: Focus Named Workspaces `"one"` through `"nine"`
* **`Mod + 0`**: Focus 10th Dynamic Workspace

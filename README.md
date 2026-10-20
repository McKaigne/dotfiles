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

## Typography & Subpixel DPI Engineering

| Target | Display Font | Terminal / Monospace Font | Target DPI (`XFT_DPI`) | True Pixel Metrics |
| :--- | :--- | :--- | :--- | :--- |
| **hyde (24" 1080p)** | Atkinson Hyperlegible | AtkynsonMono Nerd Font | `96` | 14px Foot (`size=14px`), 12pt Ghostty (16px grid) |
| **castor (15.6" 1080p)** | Atkinson Hyperlegible | AtkynsonMono Nerd Font | `141` | 14px Foot (`size=14px`), native density scaling |

---

## Keybinding Taxonomy

### Space Tree (Viewport Fill & Floating Layer)
* **`Mod + Space`**: Fill Screen (Maximize Column Width)
* **`Mod + Shift + Space`**: Fullscreen Window
* **`Mod + Ctrl + Space`**: Toggle Window Floating
* **`Mod + Alt + Space`**: Switch Focus Floating/Tiling

### Left Hand: Core Engines & Noctalia Panels
* **`Mod + F`**: Terminal: Foot Client (Fast Daemon) • **`Shift`**: Ghostty • **`Ctrl`**: Tmux Project Sessionizer
* **`Mod + D`**: Browser: LibreWolf • **`Shift`**: Brave Origin • **`Ctrl`**: Private Window
* **`Mod + S`**: Files: PCManFM • **`Shift`**: Floating PCManFM Dialog
* **`Mod + A`**: Chat: Ferdium • **`Shift`**: Niri Workspace Overview • **`Ctrl`**: Floating Ferdium
* **`Mod + G`**: Notes: Obsidian • **`Shift`**: Floating Obsidian Quick Note
* **`Mod + T`**: Snip: Area Screenshot to Clipboard • **`Shift`**: Fullscreen Screenshot
* **`Mod + E`**: Notices: Notification Center • **`Shift`**: Clear History
* **`Mod + X`**: Notices: Dismiss Active Notice
* **`Mod + V`**: Settings: Noctalia Settings GUI • **`Shift`**: Clipboard History Panel
* **`Mod + C`**: Control Center • **`Shift`**: Pavucontrol Mixer
* **`Mod + B`**: Bluetooth Panel • **`Shift`**: Bitwarden Desktop Client
* **`Mod + W`**: Wi-Fi Panel • **`Shift`**: Wallpaper Panel • **`Ctrl`**: Toggle Top Bar
* **`Mod + R`**: Launcher: Noctalia App Runner • **`Shift`**: Interactive Fuzzel Cheat Sheet
* **`Mod + Esc`**: Session Menu • **`Shift`**: Lock Screen • **`Ctrl`**: Turn Off Displays
* **`Mod + Q`**: Close Window • **`Shift`**: Kill Window

### Right Hand: Coalesced HJKL Navigation, Movement & Resizing
* **`Mod + H / L`**: Focus Column Left / Right
* **`Mod + J / K`**: Focus Window Down / Up (inside column stack)
* **`Mod + Shift + H / L`**: Move Column Left / Right
* **`Mod + Shift + J / K`**: Move Window Down / Up (inside column stack)
* **`Mod + Ctrl + H / L`**: Shrink / Expand Column Width (`-5%` / `+5%`)
* **`Mod + Ctrl + J / K`**: Shrink / Expand Window Height (`-5%` / `+5%`)
* **`Mod + U / I`**: Focus Workspace Down / Up • **`Shift`**: Move Column to Workspace Down / Up
* **`Mod + M`**: Consume Window into Column from Left
* **`Mod + ,` (Comma)**: Consume Window into Column from Right
* **`Mod + .` (Period)**: Expel Window from Column
* **`Mod + 1..9`**: Focus Named Workspaces `"one"` through `"nine"`
* **`Mod + 0`**: Focus 10th Dynamic Workspace

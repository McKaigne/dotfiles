{ config, pkgs, lib, inputs, ... }: {
  imports = [
    # Hardware & Baseline
    ./hardware.nix
    ../../modules/core
    ../../modules/hardware/audio
    ../../modules/hardware/bluetooth
    ../../modules/hardware/graphics/amd  # AMD RDNA 3 + HIP compute
    ../../modules/hardware/kanata        # Runs Weikav Alice and Flow84

    # Desktop Shell & Compositor
    ../../modules/desktop/niri
    ../../modules/desktop/noctalia
    ../../modules/desktop/fuzzel
    ../../modules/desktop/theme
    ../../modules/desktop/fonts
    ../../modules/desktop/xdg

    # Terminal & Editor
    ../../modules/terminal/ghostty
    ../../modules/terminal/zellij
    ../../modules/terminal/shell
    ../../modules/editor/neovim

    # Web Browser
    ../../modules/browser/brave

    # Media Suite
    ../../modules/media/cliamp
    ../../modules/media/parabolic
    ../../modules/media/mpv
    ../../modules/media/imv

    # Document Suite
    ../../modules/documents/zathura
    ../../modules/documents/onlyoffice
    ../../modules/documents/obsidian

    # Creative Production Suite
    ../../modules/creative/blender
    ../../modules/creative/kdenlive
    ../../modules/creative/krita
    ../../modules/creative/obs

    # Development & Engines
    ../../modules/dev/toolchain
    ../../modules/dev/godot

    # Network & Security
    ../../modules/network/localsend
    ../../modules/security/bitwarden
  ];

  networking.hostName = "hyde";
  mainUser = "jekyll";

  time.timeZone = "Asia/Manila";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  programs.nix-ld.enable = true;

  # Include all default storage and PCIe bus drivers in early initrd (matching the Live USB)
  boot.initrd.includeDefaultModules = true;

  # Drop into an interactive root shell instead of panicking if a mount error occurs
  boot.shell_on_fail = true;

  # Hardware fix for Kingston NV2 on AMD platforms (disable broken APST & PCIe ASPM)
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0"
    "pcie_aspm=off"
  ];

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  security.sudo.extraConfig = ''
    Defaults passwd_timeout=0
    Defaults timestamp_timeout=30
  '';

  system.stateVersion = "25.05";
}

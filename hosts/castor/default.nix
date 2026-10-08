{ config, pkgs, lib, inputs, ... }: {
  imports = [
    # Hardware & Baseline
    ./hardware.nix
    ../../modules/core
    ../../modules/hardware/audio
    ../../modules/hardware/bluetooth
    ../../modules/hardware/graphics/intel  # Intel Iris Xe
    ../../modules/hardware/kanata

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

  networking.hostName = "castor";
  mainUser = "pollux";

  time.timeZone = "Asia/Manila";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.nix-ld.enable = true;

  boot.kernelParams = [
    "nowatchdog"
  ];

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1 power_save_controller=Y
  '';

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.dirty_expire_centisecs" = 6000;
    "vm.dirty_ratio" = 20;
    "vm.dirty_background_ratio" = 5;
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.openssh.enable = true;

  security.sudo.extraConfig = ''
    Defaults passwd_timeout=0
    Defaults timestamp_timeout=30
  '';

  system.stateVersion = "25.05";
}

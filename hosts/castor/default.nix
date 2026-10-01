{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./hardware.nix
    ../../modules/core.nix
    ../../modules/hardware/audio.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/graphics.nix
    ../../modules/hardware/kanata.nix
    ../../modules/desktop/niri
    ../../modules/desktop/noctalia.nix
    ../../modules/terminal/ghostty.nix
    ../../modules/terminal/zellij.nix
    ../../modules/terminal/shell
    ../../modules/editor/helix
    ../../modules/apps/qutebrowser
    ../../modules/apps/fuzzel
    ../../modules/apps/helium.nix
    ../../modules/apps/viewers.nix
    ../../modules/apps/ytm-player.nix
  ];

  networking.hostName = "castor";
  time.timeZone = "Asia/Manila";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.nix-ld.enable = true;

  boot.kernelParams = [
    "i915.enable_fbc=1"
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
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 1024;
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.openssh.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.niri}/bin/niri --session";
        user = config.mainUser;
      };
    };
  };

  security.sudo.extraConfig = ''
    Defaults passwd_timeout=0
    Defaults timestamp_timeout=30
  '';

  system.stateVersion = "25.05";
}

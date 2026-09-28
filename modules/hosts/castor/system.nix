{ ... }: {
  flake.nixosModules.castorSystem = { config, pkgs, ... }: {
    networking.hostName = "castor";
    time.timeZone = "Asia/Manila";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    programs.nix-ld.enable = true;

    # Safe Tiger Lake parameters (removed aggressive ASPM and PSR that break I2C touchpads)
    boot.kernelParams = [
      "i915.enable_fbc=1"      # Framebuffer compression (safe power savings without micro-stutter)
      "nowatchdog"             # Disables hardware watchdog wakeups
    ];

    # Audio chipset power-down when idle
    boot.extraModprobeConfig = ''
      options snd_hda_intel power_save=1 power_save_controller=Y
    '';

    # In-Memory Compilation (tmpfs)
    boot.tmp.useTmpfs = true;
    boot.tmp.tmpfsSize = "50%";

    # ZRAM & Kernel Sysctl Optimization
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

    networking.networkmanager.wifi.powersave = true;

    services.thermald.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    services.openssh.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
      ];
      config.niri = {
        default = [ "gnome" "gtk" ];
      };
    };

    security.sudo.extraConfig = ''
      Defaults passwd_timeout=0
      Defaults timestamp_timeout=30
    '';

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${config.programs.niri.package}/bin/niri --session";
          user = config.mainUser;
        };
      };
    };

    networking.networkmanager.enable = true;
    system.stateVersion = "25.05";
  };
}

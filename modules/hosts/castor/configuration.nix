{ ... }: {
  flake.nixosModules.castorConfiguration = { config, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
    };

    networking.hostName = "castor";
    time.timeZone = "Asia/Manila";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    programs.nix-ld.enable = true;

    # Compressed in-RAM swap to guarantee OOM immunity during heavy compilation
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    # Intel Tiger Lake thermal governor
    services.thermald.enable = true;

    hardware.enableRedistributableFirmware = true;
    hardware.firmware = with pkgs; [
      sof-firmware
      alsa-firmware
    ];

    hardware.graphics.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    services.openssh.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          FastConnectable = true;
          Experimental = true;
        };
      };
    };
    services.blueman.enable = true;

    # Universal udev rule: Matches Lofree Flow84 whether Wired (USB) or Bluetooth!
    services.udev.extraRules = ''
      KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="*Flow84*|*Lofree*", SYMLINK+="input/by-id/lofree-flow84", TAG+="uaccess"
    '';

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${config.programs.niri.package}/bin/niri";
          user = config.mainUser;
        };
      };
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    users.users.${config.mainUser} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "uinput" ];
    };

    networking.networkmanager.enable = true;
    system.stateVersion = "25.05";
  };
}
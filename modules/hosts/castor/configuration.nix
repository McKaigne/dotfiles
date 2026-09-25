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

    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

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
          Experimental = true;
          JustWorksRepairing = "always";
        };
        Input = {
          ClassicBondedOnly = false;
        };
      };
    };
    services.blueman.enable = true;

    services.udev.extraRules = ''
      KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="*[Ff]low84*", SYMLINK+="input/by-id/lofree-flow84", TAG+="uaccess"
      KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="*[Ll]ofree*", SYMLINK+="input/by-id/lofree-flow84", TAG+="uaccess"
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
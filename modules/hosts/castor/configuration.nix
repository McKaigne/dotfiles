{ self, ... }: {
  flake.nixosModules.castorConfiguration = { config, pkgs, lib, ... }: {
    imports = [
      self.nixosModules.castorHardware
      self.nixosModules.user
      self.nixosModules.niri
      self.nixosModules.nushell
      self.nixosModules.emacs
      self.nixosModules.helix
      self.nixosModules.tmux
      self.nixosModules.ghostty
      self.nixosModules.yazi
      self.nixosModules.cava
      self.nixosModules.fuzzel
      self.nixosModules.helium
      self.nixosModules.desktop
      self.nixosModules.kanata
      self.nixosModules.thunar
      self.nixosModules.cursor
    ];

    nixpkgs.config.allowUnfree = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    networking.hostName = "castor";
    time.timeZone = "Asia/Manila";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

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
    };
    services.blueman.enable = true;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "niri";
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
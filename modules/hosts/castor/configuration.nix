{ self, ... }: {
  flake.nixosModules.castorConfiguration = { config, pkgs, lib, ... }: {
    imports = [
      self.nixosModules.castorHardware
      self.nixosModules.homeManager
      self.nixosModules.niri
      self.nixosModules.nushell
      self.nixosModules.emacs
      self.nixosModules.helix
      self.nixosModules.tmux
      self.nixosModules.helium
      self.nixosModules.desktop
      self.nixosModules.kanata
      self.nixosModules.thunar
      self.nixosModules.cursor
    ];

    dotfiles.path = "/etc/nixos/dotfiles";

    nixpkgs.config.allowUnfree = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    networking.hostName = "castor";
    time.timeZone = "Asia/Manila";

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Hardware & Audio DSP Firmware (Intel Tiger Lake SOF)
    hardware.enableRedistributableFirmware = true;
    hardware.firmware = with pkgs; [
      sof-firmware
      alsa-firmware
    ];

    hardware.graphics.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    services.openssh.enable = true;

    # Bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;

    # Display Manager (Autologin to Niri)
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "niri";
          user = config.mainUser;
        };
      };
    };

    # Audio (PipeWire + WirePlumber)
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # User Account
    users.users.${config.mainUser} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "uinput" ];
    };

    networking.networkmanager.enable = true;
    system.stateVersion = "25.05";
  };
}
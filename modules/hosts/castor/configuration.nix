
{ self, ... }: {
  flake.nixosModules.castorConfiguration = { pkgs, ... }: {
    imports = [
      self.nixosModules.castorHardware
      self.nixosModules.niri
      self.nixosModules.nushell
      self.nixosModules.emacs
      self.nixosModules.helium
      self.nixosModules.desktop
    ];

    nixpkgs.config.allowUnfree = true;

    networking.hostName = "castor";

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # -----------------------------------------------------------------
    # Bluetooth Configuration
    # -----------------------------------------------------------------
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;

    # Hardware & Power
    hardware.graphics.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    services.openssh.enable = true;

    # Keyboard & Key Remap
    services.xserver.xkb = {
      layout = "us";
      options = "caps:escape";
    };
    console.useXkbConfig = true;

    # Display Manager (Autologin to Niri)
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "niri";
          user = "pollux";
        };
      };
    };

    # Audio (PipeWire)
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # User Account
    users.users.pollux = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    };

    networking.networkmanager.enable = true;
    system.stateVersion = "25.05";
  };
}

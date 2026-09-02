{ self, inputs, ... }: {
  flake.nixosModules.castorConfiguration = { config, lib, pkgs, ... }: {
    imports = [
      self.nixosModules.castorHardware
      self.nixosModules.helium
      self.nixosModules.emacs
      self.nixosModules.desktop
      self.nixosModules.nushell
      self.nixosModules.niri
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    # Bootloader & Quiet Boot
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelParams = [ "quiet" "loglevel=3" "rd.systemd.show_status=auto" "rd.udev.log_level=3" ];

    networking.hostName = "castor";
    networking.networkmanager.enable = true;

    # Hardware & Power
    hardware.bluetooth.enable = true;
    hardware.graphics.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
    services.openssh.enable = true;

    # System-wide Cursor
    environment.sessionVariables = {
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "16";
      HYPRCURSOR_THEME = "Bibata-Modern-Classic";
      HYPRCURSOR_SIZE = "16";
    };

    # Auto-login to Niri
    services.greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "niri-session";
          user = "pollux";
        };
        default_session = {
          command = "niri-session";
          user = "pollux";
        };
      };
    };

    # Direnv
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
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
      extraGroups = [ "wheel" "networkmanager" ];
      packages = with pkgs; [
        tree
        xwayland-satellite
      ];
    };

    time.timeZone = "Asia/Manila";
    services.xserver.xkb.options = "caps:escape";
    console.useXkbConfig = true;
    system.stateVersion = "25.11";
  };
}


{ self, ... }: {
  flake.nixosModules.castorConfiguration = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.castorHardware
      self.nixosModules.dotfiles
      self.nixosModules.niri
      self.nixosModules.nushell
      self.nixosModules.emacs
      self.nixosModules.helium
      self.nixosModules.desktop
      self.nixosModules.kanata
    ];

    nixpkgs.config.allowUnfree = true;

    # Enable Flakes & nix-command permanently
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    networking.hostName = "castor";
    time.timeZone = "Asia/Manila";

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # System-wide Unified Cursor Environment Variables
    environment.sessionVariables = {
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "16";
      HYPRCURSOR_THEME = "Bibata-Modern-Classic";
      HYPRCURSOR_SIZE = "16";
      XCURSOR_PATH = lib.mkForce [ "$HOME/.icons" "$HOME/.local/share/icons" "/run/current-system/sw/share/icons" ];
      NIXOS_OZONE_WL = "1"; # Ensures Helium/Chromium runs pure Wayland and uses Wayland cursor
    };

    # Bluetooth
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
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "uinput" ];
    };

    networking.networkmanager.enable = true;
    system.stateVersion = "25.05";
  };
}

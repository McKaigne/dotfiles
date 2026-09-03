
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

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    services.xserver.xkb = {
      layout = "us";
      options = "caps:escape";
    };
    console.useXkbConfig = true;

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "niri-session";
          user = "pollux";
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

    users.users.pollux = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    };

    networking.networkmanager.enable = true;

    system.stateVersion = "25.05";
  };
}

{config, ...}: let
  m = config.flake.modules;
  base = config.nixos.base;
in {
  flake.modules.nixos.host-common = {config, ...}: {
    imports = with m.nixos; [
      m.generic.workstation-options
      base
      user-workstation
      gtk
      qt
      cursor
      fish
      git
      cli
      librewolf
      helium
      noctalia
      noctalia-plymouth
      noctalia-greeter-package
      media-tools
      pcmanfm
      zathura
      onlyoffice
      krita
      kdenlive
    ];
    # Per-host monitor layout for the active desktop.
    home-manager.sharedModules = [
      m.homeManager."host-${config.workstation.hostname}-display-${config.workstation.desktop}"
    ];
    nixpkgs.hostPlatform = config.workstation.system;
    networking.hostName = config.workstation.hostname;
    system.stateVersion = config.workstation.stateVersion;
  };
}

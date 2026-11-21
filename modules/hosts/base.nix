{ config, ... }:
let
  m = config.flake.modules;
  nixosBase = config.nixos.base;
in
{
  flake.modules.nixos.host-workstation =
    { config, ... }:
    {
      imports = with m.nixos; [
        m.generic.workstation-options
        nixosBase
        user-workstation
        m.nixos."desktop-umbriel"
        noctalia-greeter-package
        noctalia-greeter
        noctalia-plymouth
        gtk
        qt
        cursor
        fish
        git
        cli
        librewolf
        helium
        noctalia
        pcmanfm
        zathura
        mpv
        onlyoffice
        krita
        kdenlive
        media-tools
      ];

      nixpkgs.hostPlatform = config.workstation.system;
      networking.hostName = config.workstation.hostname;
      system.stateVersion = config.workstation.stateVersion;
    };
}

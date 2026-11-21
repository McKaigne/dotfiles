{ config, ... }:
let
  m = config.flake.modules;
  nixosBase = config.nixos.base;
in
{
  flake.modules.nixos.host-workstation =
    { config, lib, ... }:
    {
      imports = with m.nixos; [
        m.generic.workstation-options
        nixosBase
        user-workstation
        desktop-niri
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

      assertions = [
        {
          assertion =
            let
              user = config.workstation.username;
              niriCfg = config.home-manager.users.${user}.programs.niri.finalConfig or "";
            in
            !lib.hasInfix "xray true" niriCfg;
          message = "Niri config must never enable xray true.";
        }
      ];

      nixpkgs.hostPlatform = config.workstation.system;
      networking.hostName = config.workstation.hostname;
      system.stateVersion = config.workstation.stateVersion;
    };
}

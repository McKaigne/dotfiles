{ config, ... }:
let
  m = config.flake.modules;
in
{
  flake.modules.nixos.user-workstation =
    { config, ... }:
    {
      home-manager.users.${config.workstation.username}.imports = [
        m.homeManager.user-workstation
      ];
    };

  flake.modules.homeManager.user-workstation =
    { config, ... }:
    let
      avatarSrc = ../../avatar.jpg;
    in
    {
      imports = with m.homeManager; [
        emacs
        development
        foot
        zellij
        helix
        btop
        icons
        cli
        fuzzel
        microfetch
        nitch
        bitwarden
        imv
      ];

      home = {
        username = config.workstation.username;
        homeDirectory = "/home/${config.workstation.username}";
        stateVersion = config.workstation.stateVersion;
        sessionVariables = {
          EDITOR = "emacs";
          VISUAL = "emacs";
          TERMINAL = "foot";
        };
        file = {
          ".face" = {
            source = avatarSrc;
            force = true;
          };
          ".face.icon" = {
            source = avatarSrc;
            force = true;
          };
        };
      };

      programs.home-manager.enable = true;
    };
}

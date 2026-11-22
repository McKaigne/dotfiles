{config, ...}: let
  m = config.flake.modules;
in {
  flake.modules.nixos.user-workstation = {config, ...}: {
    home-manager.users.${config.workstation.username}.imports = [m.homeManager.user-workstation];
  };
  flake.modules.homeManager.user-workstation = {config, ...}: let
    avatar = ../../../avatar.jpg;
  in {
    imports = with m.homeManager; [
      emacs
      development
      foot
      zellij
      helix
      fuzzel
      microfetch
      icons
      bitwarden
      btop
      mpv
      imv
    ];
    home = {
      username = config.workstation.username;
      homeDirectory = "/home/${config.workstation.username}";
      stateVersion = config.workstation.stateVersion;
      sessionVariables = {
        EDITOR = "hx";
        VISUAL = "hx";
        TERMINAL = "foot";
      };
      file = {
        ".face" = {
          source = avatar;
          force = true;
        };
        ".face.icon" = {
          source = avatar;
          force = true;
        };
      };
    };
    # Also for apps started by systemd or the compositor, not only shells.
    systemd.user.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
    programs.home-manager.enable = true;
  };
}

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
      foot
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
      # Emacs: a new window on the daemon that closes when you finish the
      # file (C-x #, or C-c C-c in a commit message).
      sessionVariables = {
        EDITOR = "emacsclient";
        VISUAL = "emacsclient";
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
      EDITOR = "emacsclient";
      VISUAL = "emacsclient";
    };
    programs.home-manager.enable = true;
  };
}

{ ... }: {
  flake.nixosModules.core = { config, pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
      keep-outputs = true;
      keep-derivations = true;
    };

    # Polkit Privilege Escalation
    security.polkit.enable = true;
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # GVFS Daemon: Required for Nautilus trash://, USB drive automounting, and MTP mobile devices
    services.gvfs.enable = true;

    users.users.${config.mainUser} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "uinput" ];
    };

    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      BAT_THEME = "noctalia";
      NNN_OPTS = "aep";
    };

    environment.etc."xdg/direnv/direnv.toml".text = ''
      [whitelist]
      prefix = [
        "/home/${config.mainUser}/Projects",
        "/home/${config.mainUser}/projects"
      ]
    '';

    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "org.gnome.Nautilus.desktop";
        "application/x-directory" = "org.gnome.Nautilus.desktop";
        "inode/mount-point" = "org.gnome.Nautilus.desktop";
        "x-scheme-handler/file" = "org.gnome.Nautilus.desktop";
      };
    };

    environment.systemPackages = with pkgs; [
      # Modern GTK4 / Libadwaita File Manager
      nautilus
      whitesur-icon-theme

      # Applications
      pear-desktop
      libreoffice-stable
      yazi
      nnn
      aria2

      # Native Tree & Core CLI
      tree
      bottom
      fetch
      bat
      git
      curl
      ripgrep
      fd
      findutils
      wl-clipboard
      eza
      dust
      procs
      tealdeer
      direnv
      devenv
      p7zip
      unrar
      jq
      lazygit
      gh
      adwaita-icon-theme
      hicolor-icon-theme

      # Antigravity CLI wrapper
      (pkgs.antigravity-cli or (pkgs.writeShellScriptBin "agy" ''
        if command -v antigravity-cli &>/dev/null; then
          exec antigravity-cli "$@"
        else
          exec nix run "github:antigravity-cli/antigravity" -- "$@"
        fi
      ''))
    ];

    environment.etc."gitconfig".text = ''
      [core]
        pager = delta
        editor = hx
      [interactive]
        diffFilter = delta --color-only
      [delta]
        navigate = true
        light = false
        line-numbers = true
        side-by-side = false
        syntax-theme = "base16"
    '';

    fonts.packages = with pkgs; [
      maple-mono.NF-unhinted
      symbola
      nerd-fonts.symbols-only
    ];
  };
}

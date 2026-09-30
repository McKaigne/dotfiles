{ config, pkgs, lib, inputs, ... }:
let
  user = config.mainUser;
  bibataCursorsFixed = pkgs.runCommand "bibata-modern-classic-fixed" { } ''
    mkdir -p $out/share/icons
    cp -r ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic $out/share/icons/Bibata-Modern-Classic
    chmod -R u+w $out/share/icons/Bibata-Modern-Classic
    cd $out/share/icons/Bibata-Modern-Classic/cursors
    [ -e hand2 ] || ln -sf pointer hand2
    [ -e sb_v_double_arrow ] || ln -sf ns-resize sb_v_double_arrow
    [ -e sb_h_double_arrow ] || ln -sf ew-resize sb_h_double_arrow
  '';
in
{
  options.mainUser = lib.mkOption {
    type = lib.types.str;
    default = "pollux";
    description = "Primary workstation user account";
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
      keep-outputs = true;
      keep-derivations = true;
      substituters = [
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    programs.dconf.enable = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = { inherit inputs; };
      users.${user} = {
        home.stateVersion = "25.05";
        programs.home-manager.enable = true;

        gtk = {
          enable = true;
          theme = {
            name = "adw-gtk3-dark";
            package = pkgs.adw-gtk3;
          };
          iconTheme = {
            name = "WhiteSur";
            package = pkgs.whitesur-icon-theme;
          };
          gtk4.theme = null;
        };

        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "WhiteSur";
        };

        xdg.configFile."gtk-3.0/gtk.css" = {
          text = "@import 'noctalia.css';\n";
          force = true;
        };

        xdg.configFile."gtk-4.0/gtk.css" = {
          text = "@import 'noctalia.css';\n";
          force = true;
        };
      };
    };

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

    services.gvfs.enable = true;

    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "uinput" ];
    };

    qt = {
      enable = true;
      platformTheme = "qt5ct";
      style = "adwaita-dark";
    };

    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
      BAT_THEME = "noctalia";
      NNN_OPTS = "aep";
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "16";
      NIXOS_OZONE_WL = "1";
      GTK_THEME = "adw-gtk3-dark";
    };

    environment.etc."xdg/direnv/direnv.toml".text = ''
      [whitelist]
      prefix = [
        "/home/${user}/Projects",
        "/home/${user}/projects"
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
      # =========================================================================
      # Core GUI & Desktop Integration
      # =========================================================================
      nautilus
      whitesur-icon-theme
      adw-gtk3
      bibataCursorsFixed
      libsForQt5.qt5ct
      (pkgs.qt6Packages.qt6ct or pkgs.kdePackages.qt6ct)
      adwaita-icon-theme
      hicolor-icon-theme

      # =========================================================================
      # Wayland Display & Clipboard Utilities
      # =========================================================================
      cliphist
      satty
      hyprpicker
      wl-clipboard

      # =========================================================================
      # Terminal Navigation & Process Monitoring
      # =========================================================================
      tree
      bottom
      fetch
      bat
      eza
      dust
      gdu
      procs
      tealdeer
      trippy

      # =========================================================================
      # Data Processing & Text Transformation
      # =========================================================================
      ripgrep
      fd
      findutils
      jq
      jnv
      sd
      xh
      curl

      # =========================================================================
      # Development, Version Control & Benchmarking
      # =========================================================================
      git
      delta
      lazygit
      gh
      hyperfine
      tokei
      glow
      lazydocker

      # =========================================================================
      # Nix Ecosystem & Flake Tooling
      # =========================================================================
      direnv
      devenv
      nvd
      nix-output-monitor
      nix-tree
      manix
      nix-init
      nix-melt

      # =========================================================================
      # Declarative Secrets & Encryption (SOPS / Age / SecretSpec)
      # =========================================================================
      (pkgs.secretspec or (pkgs.writeShellScriptBin "secretspec" ''
        exec nix run "github:cachix/secretspec" -- "$@"
      ''))
      sops
      age
      ssh-to-age

      # =========================================================================
      # Applications, Media & Archive Tools
      # =========================================================================
      pear-desktop
      libreoffice-stable
      yazi
      nnn
      aria2
      p7zip
      unrar

      # =========================================================================
      # Custom Script Wrappers
      # =========================================================================
      (pkgs.antigravity-cli or (pkgs.writeShellScriptBin "agy" ''
        if command -v antigravity-cli &>/dev/null; then
          exec antigravity-cli "$@"
        else
          exec nix run "github:antigravity-cli/antigravity" -- "$@"
        fi
      ''))
    ];

    fonts = {
      packages = with pkgs; [
        nerd-fonts.lilex
        symbola
        nerd-fonts.symbols-only
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "Lilex Nerd Font" ];
        };
      };
    };
  };
}

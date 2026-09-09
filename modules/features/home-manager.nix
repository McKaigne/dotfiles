{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { config, lib, pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    options.mainUser = lib.mkOption {
      type = lib.types.str;
      default = "pollux";
      description = "Primary user account configured by home-manager";
    };

    options.dotfiles = {
      path = lib.mkOption {
        type = lib.types.str;
        default = "/etc/nixos/dotfiles";
        description = "Absolute path to the dotfiles directory for out-of-store symlinks";
      };
    };

    config = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = {
        dotfilesPath = config.dotfiles.path;
        cursorConfig = config.cursor;
      };
      home-manager.users.${config.mainUser} = { config, dotfilesPath, cursorConfig, ... }:
        let
          link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
        in {
          home.stateVersion = "25.05";
          home.pointerCursor = {
            enable = true;
            name = cursorConfig.theme;
            package = cursorConfig.package;
            size = cursorConfig.size;
            gtk.enable = true;
            x11.enable = true;
          };

          gtk = {
            enable = true;
            theme = {
              name = "adw-gtk3-dark";
              package = pkgs.adw-gtk3;
            };
            iconTheme = {
              name = "Adwaita";
              package = pkgs.adwaita-icon-theme;
            };
            gtk4.theme = null;
            gtk3.extraCss = ''
              @import url("file://${config.home.homeDirectory}/.config/gtk-3.0/noctalia.css");
            '';
            gtk4.extraCss = ''
              @import url("file://${config.home.homeDirectory}/.config/gtk-4.0/noctalia.css");
            '';
          };

          xdg.mimeApps = {
            enable = true;
            defaultApplications = {
              "inode/directory" = [ "thunar.desktop" ];
              "application/x-directory" = [ "thunar.desktop" ];
              "inode/mount-point" = [ "thunar.desktop" ];
              "x-scheme-handler/file" = [ "thunar.desktop" ];
              "text/plain" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
              "text/x-c" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
              "text/x-c++src" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
              "text/x-c++hdr" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
              "text/x-csrc" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
              "text/x-chdr" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
              "text/x-rust" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
              "text/x-elixir" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
              "application/json" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
            };
          };

          xdg.configFile = {
            "niri/config.kdl".source = link "niri/config.kdl";
            "nushell/config.nu".source = link "nushell/config.nu";
            "nushell/env.nu".source = link "nushell/env.nu";
            "starship/starship.toml".source = link "starship/starship.toml";
            "cava/config".source = link "cava/config";
            "ghostty/config".source = link "ghostty/config";
            "ghostty/shaders/cursor_smear_fade.glsl".source = link "ghostty/shaders/cursor_smear_fade.glsl";
            "fuzzel/fuzzel.ini".source = link "fuzzel/fuzzel.ini";
            "yazi/yazi.toml".source = link "yazi/yazi.toml";
            "helix/config.toml".source = link "helix/config.toml";
            "tmux/tmux.conf".source = link "tmux/tmux.conf";
            "Thunar/uca.xml".source = link "Thunar/uca.xml";
            "xfce4/helpers.rc".source = link "xfce4/helpers.rc";
            "doom/config.el".source = link "doom/config.el";
            "doom/init.el".source = link "doom/init.el";
            "doom/custom.el".source = link "doom/custom.el";
            "doom/packages.el".source = link "doom/packages.el";
            "doom/carabao.svg".source = link "doom/carabao.svg";
            "doom/themes/doom-nano-dark-theme.el".source = link "doom/themes/doom-nano-dark-theme.el";
            "doom/themes/doom-nano-light-theme.el".source = link "doom/themes/doom-nano-light-theme.el";
            "doom/themes/noctalia-theme.el".source = link "doom/themes/noctalia-theme.el";
          };
        };
    };
  };
}
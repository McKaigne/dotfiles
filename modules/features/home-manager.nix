
{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { inputs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.pollux = { config, ... }:
      let
        link = path: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${path}";
      in
      {
        home.stateVersion = "25.05";

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "inode/directory" = [ "thunar.desktop" ];
            "application/x-directory" = [ "thunar.desktop" ];
            "inode/mount-point" = [ "thunar.desktop" ];
            "x-scheme-handler/file" = [ "thunar.desktop" ];
          };
        };

        xdg.configFile = {
          "niri/config.kdl".source        = link "niri/config.kdl";
          "nushell/config.nu".source      = link "nushell/config.nu";
          "nushell/env.nu".source         = link "nushell/env.nu";
          "starship/starship.toml".source = link "starship/starship.toml";
          "gtk-3.0/gtk.css".source        = link "gtk-3.0/gtk.css";
          "gtk-4.0/gtk.css".source        = link "gtk-4.0/gtk.css";
          "cava/config".source            = link "cava/config";
          "ghostty/config".source         = link "ghostty/config";
          "fuzzel/fuzzel.ini".source      = link "fuzzel/fuzzel.ini";

          "doom/config.el".source    = link "doom/config.el";
          "doom/init.el".source      = link "doom/init.el";
          "doom/custom.el".source    = link "doom/custom.el";
          "doom/packages.el".source  = link "doom/packages.el";
          "doom/carabao.svg".source  = link "doom/carabao.svg";
          "doom/themes/doom-nano-dark-theme.el".source  = link "doom/themes/doom-nano-dark-theme.el";
          "doom/themes/doom-nano-light-theme.el".source = link "doom/themes/doom-nano-light-theme.el";
          "doom/themes/noctalia-theme.el".source        = link "doom/themes/noctalia-theme.el";
        };
      };
  };
}

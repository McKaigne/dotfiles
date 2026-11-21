{ config, ... }:
{
  flake.modules.nixos.gtk =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ config.flake.modules.homeManager.gtk ];
      programs.dconf.enable = true;
      environment.systemPackages = with pkgs; [
        gnome-themes-extra
        adw-gtk3
        gruvbox-plus-icons
      ];
    };

  flake.modules.homeManager.gtk =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      gtkCssBase = ''
        * {
          border-radius: 4px !important;
        }

        headerbar windowcontrols,
        headerbar button.close,
        tab button.close,
        button.close {
          display: none;
          margin: 0;
          padding: 0;
        }

        .pcmanfm-sidebar,
        pcmanfm frame,
        pcmanfm treeview {
          border: none;
          box-shadow: none;
        }

        @import url("noctalia.css");
      '';
    in
    {
      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        iconTheme = {
          name = "Gruvbox-Plus-Dark";
          package = pkgs.gruvbox-plus-icons;
        };
        font = {
          name = "Maple Mono NF";
          size = 10;
          package = pkgs.maple-mono.NF;
        };
        gtk4.theme = null;
      };

      dconf.settings."org/gnome/desktop/interface" = {
        font-name = "Maple Mono NF 10";
        document-font-name = "Maple Mono NF 10";
        monospace-font-name = "Maple Mono NF 10";
      };

      xdg.configFile = {
        "gtk-3.0/gtk.css" = {
          text = gtkCssBase;
          force = true;
        };
        "gtk-4.0/gtk.css" = {
          text = gtkCssBase;
          force = true;
        };
        "gtk-3.0/settings.ini".force = true;
        "gtk-4.0/settings.ini".force = true;
      };

      # Keep GTK config files writable so Noctalia's gtk template hooks never fail with EROFS.
      home.activation.makeGtkConfigsWritable =
        lib.hm.dag.entryAfter [ "onFilesChange" ]
          ''
            for f in \
              ${lib.escapeShellArg "${config.xdg.configHome}/gtk-3.0/gtk.css"} \
              ${lib.escapeShellArg "${config.xdg.configHome}/gtk-3.0/settings.ini"} \
              ${lib.escapeShellArg "${config.xdg.configHome}/gtk-4.0/gtk.css"} \
              ${lib.escapeShellArg "${config.xdg.configHome}/gtk-4.0/settings.ini"}; do
              if [ -L "$f" ]; then
                target="$(${pkgs.coreutils}/bin/readlink -f "$f")"
                case "$target" in
                  /nix/store/*)
                    $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp --remove-destination "$target" "$f"
                    $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod u+w "$f"
                    ;;
                esac
              fi
            done
          '';

      home.packages = [ pkgs.nwg-look ];
    };
}

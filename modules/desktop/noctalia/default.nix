{ config, pkgs, inputs, lib, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  user = config.mainUser;
  noctaliaPkg = inputs.noctalia.packages.${system}.default;

  noctaliaThemeSync = pkgs.writeShellScriptBin "noctalia-theme-sync" ''
    set -euo pipefail

    MODE="prefer-dark"
    GTK_THEME="adw-gtk3-dark"

    SETTINGS="$HOME/.config/noctalia/settings.json"
    if [ -f "$SETTINGS" ]; then
      IS_DARK=$(${pkgs.jq}/bin/jq -r 'if .darkMode != null then .darkMode elif .theme.mode != null then (.theme.mode == "dark") else true end' "$SETTINGS" 2>/dev/null || echo "true")
      if [ "$IS_DARK" = "false" ]; then
        MODE="prefer-light"
        GTK_THEME="adw-gtk3"
      fi
    fi

    # Ensure GLib finds schemas for org.gnome.desktop.interface
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

    # Broadcast to GSettings and dconf so xdg-desktop-portal updates Chromium, Brave, and GTK apps live
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "$MODE" 2>/dev/null || true
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'$MODE'" 2>/dev/null || true
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'$GTK_THEME'" 2>/dev/null || true

    # Synchronize Brave Origin Preferences live if the file exists
    PREF_FILE="$HOME/.config/BraveSoftware/Brave-Origin/Default/Preferences"
    if [ -f "$PREF_FILE" ]; then
      ${pkgs.jq}/bin/jq '
        .extensions = (.extensions // {}) |
        .extensions.theme = (.extensions.theme // {}) |
        .extensions.theme.use_system = true |
        .extensions.theme.system_theme = 1
      ' "$PREF_FILE" > "$PREF_FILE.tmp" && mv "$PREF_FILE.tmp" "$PREF_FILE" 2>/dev/null || true
    fi

    if command -v niri &>/dev/null && [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      niri msg action load-config-file 2>/dev/null || true
    fi
    pkill -USR2 cava 2>/dev/null || true
    systemctl --user restart easyeffects 2>/dev/null || true
  '';
in
{
  environment.systemPackages = [
    noctaliaThemeSync
    pkgs.glib
    pkgs.dconf
    pkgs.gsettings-desktop-schemas
  ];

  home-manager.users.${user} = { lib, ... }: {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      settings = {
        theme = {
          mode = "dark";
          palette = "catppuccin-mocha";
          templates = {
            enable_builtin_templates = true;
            enable_user_templates = true;
            builtin_ids = [
              "btop"
              "cava"
              "fuzzel"
              "ghostty"
              "gtk3"
              "gtk4"
              "helix"
              "niri"
              "qt"
              "starship"
              "zathura"
            ];
            user = {
              cliamp = {
                input_path = "/home/${user}/.config/noctalia/templates/cliamp.toml";
                output_path = "/home/${user}/.config/cliamp/themes/noctalia.toml";
              };
              zellij = {
                input_path = "/home/${user}/.config/noctalia/templates/zellij.kdl";
                output_path = "/home/${user}/.config/zellij/themes/noctalia.kdl";
              };
              kde = {
                input_path = "/home/${user}/.config/noctalia/templates/kde-noctalia.colors";
                output_path = "/home/${user}/.local/share/color-schemes/noctalia.colors";
              };
            };
          };
        };
        hooks = {
          enabled = true;
          colorGeneration = "${noctaliaThemeSync}/bin/noctalia-theme-sync";
          startup = "${noctaliaThemeSync}/bin/noctalia-theme-sync";
          darkModeChange = "${noctaliaThemeSync}/bin/noctalia-theme-sync";
        };
        wallpaper = {
          enabled = true;
          directory = "/etc/nixos/wallpapers";
          change_mode = "random";
          interval_sec = 300;
          transition = "honeycomb";
        };
        nightlight = {
          enabled = true;
          day_temp = 6500;
          night_temp = 4000;
          auto_schedule = true;
        };
        bar = {
          "default" = {
            position = "bottom";
            floating = true;
            margin_ends = 6;
            margin_edge = 6;
            frame_radius = 12;
            opacity = 0.95;
            widgets_left = [ "launcher" "clock" "system-monitor" "media-mini" ];
            widgets_center = [ "workspace" ];
            widgets_right = [ "tray" "notifications" "network" "battery" "control-center" ];
          };
        };
        launcher = {
          position = "center";
          view_mode = "list";
          sort_by_used = true;
          terminal_command = "ghostty -e";
          enable_clipboard = true;
          enable_session_search = true;
        };
        control_center = {
          position = "close_to_button";
        };
        notifications = {
          location = "top_right";
          normal_timeout = 8;
          critical_timeout = 15;
          enable_markdown = true;
        };
        lockscreen = {
          countdown_sec = 10;
          allow_hibernate = false;
        };
      };
    };

    # Declarative Btop configuration: Upstream default layout + Noctalia theme
    xdg.configFile."btop/btop.conf" = {
      text = ''
        color_theme = "noctalia"
        theme_background = False
        truecolor = True
        rounded_corners = True
      '';
      force = true;
    };

    xdg.configFile."noctalia/templates/cliamp.toml" = {
      text = ''
        accent = "{{ colors.primary.default.hex }}"
        bright_fg = "{{ colors.on_surface.default.hex }}"
        fg = "{{ colors.on_surface_variant.default.hex }}"
        green = "{{ colors.primary.default.hex }}"
        yellow = "{{ colors.secondary.default.hex }}"
        red = "{{ colors.tertiary.default.hex }}"
      '';
      force = true;
    };

    xdg.configFile."noctalia/templates/zellij.kdl" = {
      text = ''
        themes {
          noctalia {
            fg "{{ colors.on_surface.default.hex }}"
            bg "{{ colors.surface.default.hex }}"
            black "{{ colors.surface_container_high.default.hex }}"
            red "{{ colors.error.default.hex }}"
            green "{{ colors.tertiary.default.hex }}"
            yellow "{{ colors.secondary.default.hex }}"
            blue "{{ colors.primary.default.hex }}"
            magenta "{{ colors.tertiary.default.hex }}"
            cyan "{{ colors.secondary.default.hex }}"
            white "{{ colors.on_surface_variant.default.hex }}"
            orange "{{ colors.primary_container.default.hex }}"
          }
        }
      '';
      force = true;
    };

    xdg.configFile."noctalia/templates/kde-noctalia.colors" = {
      text = ''
        [General]
        ColorScheme=noctalia
        Name=noctalia
        shadeSortColumn=true

        [Colors:Window]
        BackgroundNormal={{ colors.surface.default.red }},{{ colors.surface.default.green }},{{ colors.surface.default.blue }}
        BackgroundAlternate={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:View]
        BackgroundNormal={{ colors.surface.default.red }},{{ colors.surface.default.green }},{{ colors.surface.default.blue }}
        BackgroundAlternate={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Button]
        BackgroundNormal={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        BackgroundAlternate={{ colors.surface_container_high.default.red }},{{ colors.surface_container_high.default.green }},{{ colors.surface_container_high.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Selection]
        BackgroundNormal={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        BackgroundAlternate={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundNormal={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundInactive={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundActive={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundLink={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundVisited={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Tooltip]
        BackgroundNormal={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        BackgroundAlternate={{ colors.surface_container_high.default.red }},{{ colors.surface_container_high.default.green }},{{ colors.surface_container_high.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Complementary]
        BackgroundNormal={{ colors.surface.default.red }},{{ colors.surface.default.green }},{{ colors.surface.default.blue }}
        BackgroundAlternate={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Header]
        BackgroundNormal={{ colors.surface.default.red }},{{ colors.surface.default.green }},{{ colors.surface.default.blue }}
        BackgroundAlternate={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [KDE]
        colorScheme=noctalia
      '';
      force = true;
    };

    home.activation.seedNoctalia = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.config/helix/themes \
               $HOME/.config/ghostty/themes \
               $HOME/.config/niri \
               $HOME/.config/fuzzel/themes \
               $HOME/.config/gtk-3.0 \
               $HOME/.config/gtk-4.0 \
               $HOME/.config/noctalia/hooks \
               $HOME/.config/zellij/themes \
               $HOME/.config/cliamp/themes \
               $HOME/.config/btop/themes \
               $HOME/.config/qt5ct/colors \
               $HOME/.config/qt6ct/colors \
               $HOME/.local/share/color-schemes

      if [ -f $HOME/.config/noctalia/settings.json ]; then
        sed -i 's/"enableUserTheming": false/"enableUserTheming": true/g' $HOME/.config/noctalia/settings.json || true
      fi

      ln -sf ${noctaliaThemeSync}/bin/noctalia-theme-sync $HOME/.config/noctalia/hooks/theme-sync.sh
    '';
  };
}

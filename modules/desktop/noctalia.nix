{ config, pkgs, inputs, lib, ... }:
let
  user = config.mainUser;

  noctaliaThemeSync = pkgs.writeShellScriptBin "noctalia-theme-sync" ''
    set -euo pipefail
    if command -v niri &>/dev/null && [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      niri msg action load-config-file 2>/dev/null || true
    fi
    pkill -USR2 cava 2>/dev/null || true
    pkill -HUP -x qutebrowser 2>/dev/null || true
    systemctl --user restart easyeffects 2>/dev/null || true
  '';
in
{
  environment.systemPackages = [ noctaliaThemeSync ];

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
              qutebrowser = {
                input_path = "/home/${user}/.config/noctalia/templates/qutebrowser-colors.py";
                output_path = "/home/${user}/.config/qutebrowser/noctalia/colors.py";
                post_hook = "pkill -HUP -x qutebrowser 2>/dev/null || true";
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
        };
        wallpaper = {
          enabled = true;
          directory = "/home/${user}/Pictures/Wallpapers";
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

    xdg.configFile."noctalia/templates/cliamp.toml" = {
      text = ''
        bg = "none"
        accent = "{{ colors.primary.default.hex }}"
        bright_fg = "{{ colors.primary.default.hex }}"
        fg = "{{ colors.secondary.default.hex }}"
        green = "{{ colors.secondary.default.hex }}"
        yellow = "{{ colors.primary.default.hex }}"
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

    xdg.configFile."noctalia/templates/qutebrowser-colors.py" = {
      text = ''
        # Noctalia qutebrowser theme - Material Design 3 Colors
        # Auto-generated from Noctalia Template Engine

        surface = "{{ colors.surface.default.hex }}"
        surface_dim = "{{ colors.surface_container_lowest.default.hex }}"
        surface_bright = "{{ colors.surface_container_highest.default.hex }}"
        surface_container = "{{ colors.surface_container.default.hex }}"
        surface_container_low = "{{ colors.surface_container_low.default.hex }}"
        surface_container_lowest = "{{ colors.surface_container_lowest.default.hex }}"
        surface_container_high = "{{ colors.surface_container_high.default.hex }}"
        surface_container_highest = "{{ colors.surface_container_highest.default.hex }}"
        surface_variant = "{{ colors.surface_variant.default.hex }}"

        on_surface = "{{ colors.on_surface.default.hex }}"
        on_surface_variant = "{{ colors.on_surface_variant.default.hex }}"

        primary = "{{ colors.primary.default.hex }}"
        on_primary = "{{ colors.on_primary.default.hex }}"
        primary_container = "{{ colors.primary_container.default.hex }}"
        on_primary_container = "{{ colors.on_primary_container.default.hex }}"

        secondary = "{{ colors.secondary.default.hex }}"
        on_secondary = "{{ colors.on_secondary.default.hex }}"
        secondary_container = "{{ colors.secondary_container.default.hex }}"
        on_secondary_container = "{{ colors.on_secondary_container.default.hex }}"

        tertiary = "{{ colors.tertiary.default.hex }}"
        on_tertiary = "{{ colors.on_tertiary.default.hex }}"
        tertiary_container = "{{ colors.tertiary_container.default.hex }}"
        on_tertiary_container = "{{ colors.on_tertiary_container.default.hex }}"

        error = "{{ colors.error.default.hex }}"
        on_error = "{{ colors.on_error.default.hex }}"
        error_container = "{{ colors.error_container.default.hex }}"
        on_error_container = "{{ colors.on_error_container.default.hex }}"

        outline = "{{ colors.outline.default.hex }}"
        outline_variant = "{{ colors.outline_variant.default.hex }}"

        inverse_surface = "{{ colors.on_surface.default.hex }}"
        inverse_on_surface = "{{ colors.surface.default.hex }}"
        inverse_primary = "{{ colors.primary.default.hex }}"

        def hex_to_rgba(hex_color, alpha):
            hex_color = hex_color.lstrip('#')
            r = int(hex_color[0:2], 16)
            g = int(hex_color[2:4], 16)
            b = int(hex_color[4:6], 16)
            return 'rgba({}, {}, {}, {})'.format(r, g, b, alpha)
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
               $HOME/.config/qutebrowser/noctalia \
               $HOME/.config/qt5ct/colors \
               $HOME/.config/qt6ct/colors \
               $HOME/.local/share/color-schemes \
               $HOME/Pictures/Wallpapers

      ln -sf ${noctaliaThemeSync}/bin/noctalia-theme-sync $HOME/.config/noctalia/hooks/theme-sync.sh
    '';
  };
}

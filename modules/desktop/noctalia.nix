{ config, pkgs, inputs, ... }:
let
  user = config.mainUser;

  noctaliaThemeSync = pkgs.writeShellScriptBin "noctalia-theme-sync" ''
    set -euo pipefail
    if command -v niri &>/dev/null && [ -n "$WAYLAND_DISPLAY" ]; then
      niri msg action load-config-file 2>/dev/null || true
    fi
    pkill -USR2 cava 2>/dev/null || true
    pkill -HUP -x qutebrowser 2>/dev/null || true
    pkill -USR1 -x ytm 2>/dev/null || true
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
              "cava"
              "ghostty"
              "gtk3"
              "gtk4"
              "helix"
              "niri"
              "starship"
              "fuzzel"
            ];
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

    xdg.configFile."noctalia/templates/ytm-player.toml" = {
      text = ''
        [theme]
        primary = "{{ colors.primary.default.hex }}"
        secondary = "{{ colors.secondary.default.hex }}"
        accent = "{{ colors.primary.default.hex }}"
        background = "{{ colors.surface.default.hex }}"
        surface = "{{ colors.surface_container.default.hex }}"
        panel = "{{ colors.surface_container_high.default.hex }}"
        error = "{{ colors.error.default.hex }}"
        success = "{{ colors.tertiary.default.hex }}"
        warning = "{{ colors.secondary.default.hex }}"
        text = "{{ colors.on_surface.default.hex }}"
        text_muted = "{{ colors.on_surface_variant.default.hex }}"
        border = "{{ colors.outline.default.hex }}"
      '';
      force = true;
    };

    home.activation.seedNoctalia = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.config/helix/themes $HOME/.config/ghostty/themes $HOME/.config/niri $HOME/.config/fuzzel/themes $HOME/.config/gtk-3.0 $HOME/.config/gtk-4.0 $HOME/.config/noctalia/hooks $HOME/.config/zellij/themes $HOME/.config/ytm-player $HOME/Pictures/Wallpapers
      ln -sf ${noctaliaThemeSync}/bin/noctalia-theme-sync $HOME/.config/noctalia/hooks/theme-sync.sh

      # Guard against cached templates calling raw 'qutebrowser :config-source'
      find $HOME/.local/share/noctalia $HOME/.cache/noctalia $HOME/.config/noctalia -type f -name "apply.sh" -exec sed -i 's/qutebrowser :config-source/pkill -HUP -x qutebrowser 2>\/dev\/null || true/g' {} + 2>/dev/null || true

      if [ ! -f $HOME/.config/ytm-player/theme.toml ]; then
        cat << 'EOF' > $HOME/.config/ytm-player/theme.toml
[theme]
primary = "#b58900"
secondary = "#d33682"
accent = "#b58900"
background = "#002b36"
surface = "#06313c"
panel = "#08404f"
error = "#dc322f"
success = "#cb4b16"
warning = "#d33682"
text = "#839496"
text_muted = "#657b83"
border = "#31788d"
EOF
      fi

      if [ ! -f $HOME/.config/niri/noctalia.kdl ]; then
        cat << 'EOF' > $HOME/.config/niri/noctalia.kdl
layout {
  focus-ring {
    active-color "#cba6f7"
    inactive-color "#1e1e2e"
    urgent-color "#f38ba8"
  }
  border {
    active-color "#cba6f7"
    inactive-color "#1e1e2e"
    urgent-color "#f38ba8"
  }
}
EOF
      fi
      if [ ! -f $HOME/.config/ghostty/themes/noctalia ]; then
        cat << 'EOF' > $HOME/.config/ghostty/themes/noctalia
background = 1e1e2e
foreground = cdd6f4
cursor-color = cba6f7
selection-background = 313244
selection-foreground = cdd6f4
palette = 0=#1e1e2e
palette = 1=#f38ba8
palette = 2=#a6e3a1
palette = 3=#f9e2af
palette = 4=#89b4fa
palette = 5=#f5c2e7
palette = 6=#94e2d5
palette = 7=#cdd6f4
palette = 8=#45475a
palette = 9=#f38ba8
palette = 10=#a6e3a1
palette = 11=#f9e2af
palette = 12=#89b4fa
palette = 13=#f5c2e7
palette = 14=#94e2d5
palette = 15=#ffffff
EOF
      fi
      if [ ! -f $HOME/.config/helix/themes/noctalia.toml ]; then
        cat << 'EOF' > $HOME/.config/helix/themes/noctalia.toml
"attribute" = { fg = "#cba6f7", modifiers = ["bold"] }
"type" = "#cba6f7"
"constructor" = "#94e2d5"
"constant" = "#fab387"
"string" = "#94e2d5"
"comment" = { fg = "#585b70", modifiers = ["italic"] }
"variable" = "#cdd6f4"
"keyword" = { fg = "#cba6f7", modifiers = ["bold"] }
"function" = "#94e2d5"
"ui.background" = "none"
"ui.cursor" = { fg = "#11111b", bg = "#cba6f7" }
"ui.linenr" = "#585b70"
"ui.linenr.selected" = "#cba6f7"
"ui.statusline" = { fg = "#cdd6f4", bg = "#181825" }
"ui.selection" = { bg = "#313244" }
EOF
      fi
      if [ ! -f $HOME/.config/gtk-4.0/noctalia.css ]; then
        cat << 'EOF' > $HOME/.config/gtk-4.0/noctalia.css
@define-color accent_color #cba6f7;
@define-color accent_bg_color #cba6f7;
@define-color accent_fg_color #11111b;
@define-color window_bg_color #1e1e2e;
@define-color window_fg_color #cdd6f4;
@define-color view_bg_color #181825;
@define-color view_fg_color #cdd6f4;
@define-color headerbar_bg_color #181825;
@define-color headerbar_fg_color #cdd6f4;
@define-color card_bg_color #1e1e2e;
@define-color card_fg_color #cdd6f4;
@define-color popover_bg_color #1e1e2e;
@define-color popover_fg_color #cdd6f4;
@define-color dialog_bg_color #1e1e2e;
@define-color dialog_fg_color #cdd6f4;
@define-color sidebar_bg_color #181825;
@define-color sidebar_fg_color #cdd6f4;
EOF
      fi
      if [ ! -f $HOME/.config/gtk-3.0/noctalia.css ]; then
        cp $HOME/.config/gtk-4.0/noctalia.css $HOME/.config/gtk-3.0/noctalia.css
      fi
      if [ ! -f $HOME/.config/zellij/themes/noctalia.kdl ]; then
        cat << 'EOF' > $HOME/.config/zellij/themes/noctalia.kdl
themes {
  noctalia {
    fg "#e4ded2"
    bg "#0a0a12"
    black "#1c1c28"
    red "#c25b5b"
    green "#8baa82"
    yellow "#e6c27a"
    blue "#6270a8"
    magenta "#9a7398"
    cyan "#95b3b0"
    white "#f2eadf"
    orange "#c28f5b"
  }
}
EOF
      fi
    '';
  };
}

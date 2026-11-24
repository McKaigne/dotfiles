{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/35-widgets-system.toml".source = (pkgs.formats.toml {}).generate "35-widgets-system.toml" {
      "widget" = {
        "battery" = {
          "display_mode" = "graphic";
          "scale" = 0.65;
          "show_label" = false;
        };
        # CPU, RAM and temperature as bare gauges.
        "cpu" = {
          "show_value" = false;
          "visualization" = "gauge";
        };
        "ram" = {
          "show_value" = false;
          "visualization" = "gauge";
        };
        "temp" = {
          "show_value" = false;
          "visualization" = "gauge";
        };
        "gap" = {
          "type" = "spacer";
          "length" = 14;
        };
        "active_window" = {
          "colorize_icons" = true;
          "max_length" = 220;
          "title_scroll" = "on_hover";
        };
        "brightness" = {
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
        };
        "clock" = {
          "anchor" = true;
          "format" = "{:%H:%M}";
          "tooltip_format" = "{:%A, %B %d, %Y}";
        };
        "launcher" = {
          "custom_image" = "${../../../../assets/icons/nix-lavender.png}";
          "custom_image_colorize" = true;
        };
        "launcher_2" = {
          "type" = "launcher";
        };
        "network" = {
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
          "show_label" = true;
        };
        "network_rx" = {
          "network_speed_compact" = true;
          "show_value" = true;
          "visualization" = "none";
        };
        "network_tx" = {
          "network_speed_compact" = true;
          "show_value" = true;
          "visualization" = "none";
        };
        "taskbar" = {
          "colorize_icons" = true;
          "group_single_icon_per_app" = true;
          "hide_empty_workspaces" = true;
          "pinned" = [
            "pcmanfm"
          ];
          "workspace_label_placement" = "inside";
        };
        "tray" = {
          "colorize_icons" = true;
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
        };
        "tray_2" = {
          "colorize_icons" = true;
          "detached_panel" = true;
          "drawer" = true;
          "type" = "tray";
        };
        "wallpaper" = {
          "actions" = {
            "right" = "wallpaper-random";
          };
        };
        "notifications" = {
          "hide_when_no_unread" = true;
        };
        "weather" = {
          "show_condition" = false;
        };
        # Small unlabeled pills: the current one in the accent colour,
        # occupied ones in the text colour, empty ones faded.
        "workspaces" = {
          "style" = "regular";
          "pill_scale" = 0.5;
          "show_labels" = false;
          "focused_color" = "primary";
          "occupied_color" = "on_surface";
          "empty_color" = "outline_variant";
          "anchor" = true;
        };
      };
    };
  };
}

{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/35-widgets-system.toml".source = (pkgs.formats.toml {}).generate "35-widgets-system.toml" {
      "widget" = {
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
          "format" = "{:%a %d %b  %H:%M}";
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
        # Plain numbers, no pills: the current one in the accent colour,
        # occupied ones in the text colour, empty ones faded.
        "workspaces" = {
          "style" = "minimal";
          "focused_color" = "primary";
          "occupied_color" = "on_surface";
          "empty_color" = "outline_variant";
          "anchor" = true;
        };
      };
    };
  };
}

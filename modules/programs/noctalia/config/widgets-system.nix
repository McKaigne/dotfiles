{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/35-widgets-system.toml".source = (pkgs.formats.toml {}).generate "35-widgets-system.toml" {
      "widget" = {
        "active_window" = {
          "colorize_icons" = true;
        };
        "brightness" = {
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
        };
        "clock" = {
          "anchor" = true;
          "tooltip_format" = "{:%m/%d/%Y}";
        };
        "launcher_2" = {
          "type" = "launcher";
        };
        "network" = {
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
        };
        "ram" = {
          "show_value" = false;
        };
        "session" = {
          "custom_image" = "${../../../../assets/icons/nix-lavender.png}";
          "custom_image_colorize" = true;
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
        "temp" = {
          "show_value" = false;
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
        "weather" = {
          "show_condition" = false;
        };
        "workspaces" = {
          "colorize_icons" = true;
          "empty_color" = "hover";
          "enabled" = true;
          "focused_color" = "surface_container";
          "max_label_chars" = 19;
          "style" = "focus_hint";
        };
      };
    };
  };
}

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
        "brightness_minimal" = {
          "type" = "brightness";
        };
        "clock" = {
          "anchor" = true;
          "tooltip_format" = "{:%m/%d/%Y}";
        };
        "clock_minimal" = {
          "type" = "clock";
        };
        "cpu_temp_minimal" = {
          "anchor" = true;
          "show_glyph" = false;
          "show_value" = true;
          "stat" = "cpu_temp";
          "type" = "sysmon";
          "visualization" = "none";
        };
        "cpu_usage_minimal" = {
          "anchor" = true;
          "show_glyph" = false;
          "show_value" = true;
          "type" = "sysmon";
          "visualization" = "none";
        };
        "launcher_2" = {
          "type" = "launcher";
        };
        "left_bracket" = {
          "color" = "primary";
          "enabled" = false;
          "text" = "「";
          "type" = "text";
        };
        "network" = {
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
        };
        "ram" = {
          "show_value" = false;
        };
        "ram_usage_minimal" = {
          "anchor" = true;
          "show_glyph" = false;
          "show_value" = true;
          "stat" = "ram_used";
          "type" = "sysmon";
          "visualization" = "none";
        };
        "right_bracket" = {
          "color" = "primary";
          "enabled" = false;
          "text" = "」";
          "type" = "text";
        };
        "separator" = {
          "color" = "primary";
          "enabled" = false;
          "font_scale" = 0.2;
          "text" = " ";
          "type" = "text";
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
          "detached_panel" = false;
          "drawer" = true;
          "type" = "tray";
        };
        "tray_minimal" = {
          "colorize_icons" = true;
          "match_adjacent_spacing" = true;
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
        "workspace_minimal" = {
          "active_pill_size" = 0.35;
          "colorize_icons" = true;
          "empty_color" = "on_surface_variant";
          "occupied_color" = "outline_variant";
          "show_tooltip" = false;
          "style" = "minimal";
          "type" = "workspaces";
          "urgent_color" = "surface";
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

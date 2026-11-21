{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/35-widgets-system.toml".source =
        (pkgs.formats.toml { }).generate "35-widgets-system.toml"
          {
            widget = {
              brightness.enabled = true;
              brightness_minimal = {
                font_family = "GaramontoCode Nerd Font";
                type = "brightness";
              };
              clock = {
                anchor = true;
                tooltip_format = "{:%m/%d/%Y}";
              };
              clock_minimal.type = "clock";
              cpu_temp_minimal = {
                anchor = true;
                font_family = "GaramontoCode Nerd Font";
                show_glyph = false;
                show_value = true;
                stat = "cpu_temp";
                type = "sysmon";
                visualization = "none";
              };
              cpu_usage_minimal = {
                anchor = true;
                font_family = "GaramontoCode Nerd Font";
                show_glyph = false;
                show_value = true;
                type = "sysmon";
                visualization = "none";
              };
              left_bracket = {
                color = "primary";
                enabled = false;
                font_family = "GaramontoCode Nerd Font";
                text = "「";
                type = "text";
              };
              ram_usage_minimal = {
                anchor = true;
                font_family = "GaramontoCode Nerd Font";
                show_glyph = false;
                show_value = true;
                stat = "ram_used";
                type = "sysmon";
                visualization = "none";
              };
              right_bracket = {
                color = "primary";
                enabled = false;
                font_family = "GaramontoCode Nerd Font";
                text = "」";
                type = "text";
              };
              separator = {
                color = "primary";
                enabled = false;
                font_scale = 0.2;
                text = " ";
                type = "text";
              };
              tray.drawer = true;
              tray_minimal = {
                font_family = "GaramontoCode Nerd Font";
                match_adjacent_spacing = true;
                type = "tray";
              };
              workspace_minimal = {
                active_pill_size = 0.35;
                empty_color = "on_surface_variant";
                occupied_color = "outline";
                show_tooltip = false;
                style = "minimal";
                type = "workspaces";
                urgent_color = "surface";
              };
              workspaces = {
                empty_color = "hover";
                enabled = true;
                focused_color = "surface_variant";
                max_label_chars = 19;
                style = "focus_hint";
              };
            };
          };
    };
}

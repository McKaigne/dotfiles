{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/30-bars.toml".source =
        (pkgs.formats.toml { }).generate "30-bars.toml"
          {
            bar = {
              order = [
                "fancy"
                "minimal"
              ];
              fancy = {
                enabled = true;
                background_opacity = 1.0;
                capsule_opacity = 1.0;
                shadow = false;
                font_family = "EB Garamond";
                hover_highlight = false;
                margin_ends = 0;
                radius_top_left = 0;
                radius_top_right = 0;
                widget_spacing = 8;
                start = [
                  "workspaces"
                ];
                center = [
                  "notifications"
                  "clock"
                  "media"
                ];
                end = [
                  "tray"
                  "volume"
                  "input_volume"
                  "battery"
                  "session"
                ];
              };
              minimal = {
                enabled = false;
                background_opacity = 1.0;
                capsule_opacity = 1.0;
                capsule_radius = 0;
                color = "on_surface_variant";
                font_family = "GaramontoCode Nerd Font";
                hover_highlight = false;
                margin_ends = 0;
                padding = 5;
                radius = 0;
                shadow = false;
                show_on_workspace_switch = false;
                thickness = 27;
                start = [
                  "left_bracket"
                  "cpu_usage_minimal"
                  "separator"
                  "cpu_temp_minimal"
                  "separator"
                  "ram_usage_minimal"
                  "right_bracket"
                ];
                center = [
                  "workspace_minimal"
                ];
                end = [
                  "left_bracket"
                  "tray_minimal"
                  "separator"
                  "volume_minimal"
                  "separator"
                  "volume_input_minimal"
                  "separator"
                  "brightness_minimal"
                  "separator"
                  "clock_minimal"
                  "separator"
                  "right_bracket"
                  "session"
                ];
              };
            };
          };
    };
}

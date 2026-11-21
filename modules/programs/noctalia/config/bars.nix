let
  style = import ../../../appearance/_style.nix;
in {
  flake.modules.homeManager."noctalia" = {
    config,
    pkgs,
    ...
  }: let
    # A lone column is half the viewport (screen minus outer gaps):
    # 0.5 * (width - 2*gap + gap) - gap, centered, so each side margin is
    # width/4 + 3*gap/4 (486px at 1920 wide). Unknown width: closest percentage.
    w = config.workstation.screenWidth;
    paneMargin =
      if w == null
      then "25%"
      else w / 4 + 3 * style.gap / 4;
  in {
    xdg.configFile."noctalia/30-bars.toml".source = (pkgs.formats.toml {}).generate "30-bars.toml" {
      "bar" = {
        "order" = [
          "minimal"
          "minimal-DP2"
          "fancy"
        ];
        "fancy" = {
          "center" = [
            "notifications"
            "clock"
            "media"
          ];
          "end" = [
            "tray"
            "volume"
            "input_volume"
            "session"
          ];
          "hover_highlight" = false;
          # Float the bar at the width of a lone centered window, with the
          # same corners and translucency.
          "margin_ends" = paneMargin;
          "margin_edge" = style.gap;
          "concave_edge_corners" = false;
          "radius" = style.radius;
          "background_opacity" = style.opacity;
          "compositor_blur" = true;
          "start" = [
            "workspaces"
          ];
          "widget_spacing" = 8;
        };
        "minimal" = {
          "capsule_radius" = 0;
          "center" = [
            "workspace_minimal"
          ];
          "color" = "on_surface_variant";
          "enabled" = false;
          "end" = [
            "left_bracket"
            "tray_minimal"
            "separator"
            "volume_minimal"
            "separator"
            "volume_input_minimal"
            "separator"
            "brightness_minimal"
            "separator"
            "weather"
            "separator"
            "clock_minimal"
            "separator"
            "right_bracket"
            "session"
          ];
          "hover_highlight" = false;
          "margin_ends" = 0;
          "padding" = 5;
          "radius" = 0;
          "shadow" = false;
          "show_on_workspace_switch" = false;
          "start" = [
            "left_bracket"
            "cpu_usage_minimal"
            "separator"
            "cpu_temp_minimal"
            "separator"
            "ram_usage_minimal"
            "right_bracket"
          ];
          "thickness" = 27;
          "monitor" = {
            "DP-2" = {
              "enabled" = false;
            };
          };
        };
        "minimal-DP2" = {
          "center" = [
            "cpu_usage_minimal"
            "separator"
            "cpu_temp_minimal"
            "separator"
            "ram_usage_minimal"
          ];
          "color" = "on_surface_variant";
          "enabled" = false;
          "end" = [];
          "font_scale" = 0.8499999884516001;
          "hover_highlight" = false;
          "margin_ends" = 0;
          "padding" = 5;
          "radius" = 0;
          "start" = [
            "clock_minimal"
          ];
          "thickness" = 21;
          "monitor" = {
            "DP-1" = {
              "enabled" = false;
            };
          };
        };
      };
    };
  };
}

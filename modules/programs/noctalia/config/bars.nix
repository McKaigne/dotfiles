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
          "fancy"
        ];
        "fancy" = {
          # System gauges and what's playing on the left, workspaces in the
          # middle, tray, controls and the time on the right.
          "start" = [
            "cpu"
            "ram"
            "temp"
            "gap"
            "media"
          ];
          "center" = [
            "workspaces"
          ];
          "end" = [
            "tray_2"
            "network"
            "volume"
            "input_volume"
            "brightness"
            "battery"
            "gap"
            "clock"
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
          "padding" = 18;
          "widget_spacing" = 10;
        };
      };
    };
  };
}

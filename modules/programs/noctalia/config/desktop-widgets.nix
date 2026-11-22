{
  flake.modules.homeManager."noctalia" = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # The layout below was made on a 2560x1440 screen, and Noctalia keeps
    # positions and sizes in pixels. Scale it to this machine's screen.
    w = config.workstation.screenWidth;
    scale =
      if w == null
      then 1.0
      else w / 2560.0;
    rescale = widgets:
      lib.mapAttrs (_: widget:
        widget
        // {
          cx = widget.cx * scale;
          cy = widget.cy * scale;
          box_width = widget.box_width * scale;
          box_height = widget.box_height * scale;
          placement_width = 2560.0 * scale;
          placement_height = 1440.0 * scale;
        })
      widgets;
  in {
    xdg.configFile."noctalia/40-desktop-widgets.toml".source = (pkgs.formats.toml {}).generate "40-desktop-widgets.toml" {
      "desktop_widgets" = {
        "enabled" = true;
        "schema_version" = 2;
        "widget_order" = [
          "desktop-widget-0000000000000001"
        ];
        "grid" = {
          "cell_size" = 16;
          "major_interval" = 4;
          "visible" = true;
        };
        # Audio bars along the bottom edge of the screen, full width. Its
        # colours are wallpaper-derived theme roles and it has no background.
        "widget" = rescale {
          "desktop-widget-0000000000000001" = {
            "box_height" = 240.0;
            "box_width" = 2560.0;
            "cx" = 1280.0;
            "cy" = 1320.0;
            "output" = "DP-1";
            "rotation" = 0.0;
            "type" = "audio_visualizer";
            "settings" = {
              "background" = false;
              "bands" = 60;
              "centered" = false;
              "show_when_idle" = false;
              "color_1" = "primary";
              "color_2" = "primary";
            };
          };
        };
      };
    };
  };
}

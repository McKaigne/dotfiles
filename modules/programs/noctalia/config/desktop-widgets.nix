{
  flake.modules.homeManager.noctalia =
    { config, pkgs, ... }:
    let
      out = config.workstation.display.output;
    in
    {
      xdg.configFile."noctalia/40-desktop-widgets.toml".source =
        (pkgs.formats.toml { }).generate "40-desktop-widgets.toml"
          {
            desktop_widgets = {
              schema_version = 2;
              widget_order = [
                "desktop-widget-0000000000000015"
                "desktop-widget-0000000000000014"
                "desktop-widget-0000000000000013"
                "desktop-widget-0000000000000012"
                "desktop-widget-0000000000000010"
                "desktop-widget-0000000000000001"
                "desktop-widget-0000000000000004"
                "desktop-widget-000000000000000f"
                "desktop-widget-0000000000000011"
                "desktop-widget-0000000000000016"
                "desktop-widget-0000000000000017"
                "desktop-widget-0000000000000009"
                "desktop-widget-000000000000000a"
                "desktop-widget-000000000000000c"
              ];
              grid = {
                cell_size = 16;
                major_interval = 4;
                visible = true;
              };
              widget = {
                desktop-widget-0000000000000001 = {
                  box_height = 128.0;
                  box_width = 720.0;
                  cx = 1280.0;
                  cy = 80.0;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = -3.1415927410125732;
                  type = "audio_visualizer";
                  settings = {
                    background = false;
                    bands = 60;
                    centered = false;
                    show_when_idle = false;
                  };
                };
                desktop-widget-0000000000000004 = {
                  box_height = 128.0;
                  box_width = 720.0;
                  cx = 1280.0;
                  cy = 1378.2;
                  enabled = false;
                  flip_y = true;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = -3.1415927410125732;
                  type = "audio_visualizer";
                  settings = {
                    background = false;
                    bands = 60;
                    centered = false;
                    show_when_idle = false;
                  };
                };
                desktop-widget-0000000000000009 = {
                  box_height = 76.06;
                  box_width = 130.94;
                  cx = 1157.6;
                  cy = 1232.53;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "clock";
                  settings = {
                    background = false;
                    clock_style = "digital";
                  };
                };
                desktop-widget-000000000000000a = {
                  box_height = 44.8;
                  box_width = 90.0;
                  cx = 1234.0;
                  cy = 1232.8;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "clock";
                  settings = {
                    background = false;
                    format = "{:%d\\n%m}";
                  };
                };
                desktop-widget-000000000000000c = {
                  box_height = 80.0;
                  box_width = 160.0;
                  cx = 1389.6;
                  cy = 1234.8;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "weather";
                  settings = {
                    background = false;
                    background_opacity = 1.0;
                    forecast_days = 3;
                    shadow = false;
                    show_forecast = false;
                  };
                };
                desktop-widget-000000000000000f = {
                  box_height = 201.29;
                  box_width = 111.8;
                  cx = 1565.1;
                  cy = 1294.85;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "media_player";
                  settings = {
                    album_art_background = true;
                    album_art_blur = 8;
                    audio_visualizer = true;
                    background = true;
                    background_opacity = 0.0;
                  };
                };
                desktop-widget-0000000000000010 = {
                  box_height = 217.0;
                  box_width = 125.6;
                  cx = 1565.2;
                  cy = 1295.39;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "label";
                  settings = {
                    background_opacity = 1.0;
                    opacity = 1.0;
                    title = "";
                  };
                };
                desktop-widget-0000000000000011 = {
                  box_height = 111.9;
                  box_width = 203.0;
                  cx = 993.95;
                  cy = 1296.0;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 1.5707963705062866;
                  type = "audio_visualizer";
                  settings = {
                    background = false;
                    background_opacity = 1.0;
                    bands = 68;
                    reversed = false;
                    show_wave = false;
                    show_when_idle = true;
                  };
                };
                desktop-widget-0000000000000012 = {
                  box_height = 217.61;
                  box_width = 124.2;
                  cx = 993.9;
                  cy = 1296.3;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "label";
                  settings = {
                    background_opacity = 1.0;
                    opacity = 1.0;
                    title = "";
                  };
                };
                desktop-widget-0000000000000013 = {
                  box_height = 240.0;
                  box_width = 720.0;
                  cx = 1280.0;
                  cy = 1296.0;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "label";
                  settings = {
                    background_color = "primary";
                    background_opacity = 1.0;
                    opacity = 1.0;
                    title = "";
                  };
                };
                desktop-widget-0000000000000014 = {
                  box_height = 256.0;
                  box_width = 736.0;
                  cx = 1280.0;
                  cy = 1295.7;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "label";
                  settings = {
                    background_opacity = 1.0;
                    opacity = 1.0;
                    title = "";
                  };
                };
                desktop-widget-0000000000000015 = {
                  box_height = 94.41;
                  box_width = 200.2;
                  cx = 1388.5;
                  cy = 1235.33;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "label";
                  settings = {
                    background_opacity = 1.0;
                    opacity = 1.0;
                    title = "";
                  };
                };
                desktop-widget-0000000000000016 = {
                  box_height = 95.95;
                  box_width = 200.2;
                  cx = 1389.9;
                  cy = 1234.56;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "label";
                  settings = {
                    background_opacity = 1.0;
                    opacity = 1.0;
                    title = "";
                  };
                };
                desktop-widget-0000000000000017 = {
                  box_height = 95.05;
                  box_width = 205.8;
                  cx = 1171.7;
                  cy = 1234.42;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "label";
                  settings = {
                    background_opacity = 1.0;
                    opacity = 1.0;
                    title = "";
                  };
                };
              };
            };
          };
    };
}

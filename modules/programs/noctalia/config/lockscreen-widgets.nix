{
  flake.modules.homeManager.noctalia =
    { config, pkgs, ... }:
    let
      out = config.workstation.display.output;
    in
    {
      xdg.configFile."noctalia/42-lockscreen-widgets.toml".source =
        (pkgs.formats.toml { }).generate "42-lockscreen-widgets.toml"
          {
            lockscreen_widgets = {
              enabled = true;
              schema_version = 2;
              widget_order = [
                "lockscreen-widget-0000000000000002"
                "lockscreen-login-box"
                "lockscreen-widget-0000000000000001"
              ];
              grid = {
                cell_size = 16;
                major_interval = 4;
                visible = true;
              };
              widget = {
                lockscreen-login-box = {
                  box_height = 196.0;
                  box_width = 810.0;
                  cx = 1280.0;
                  cy = 1325.9;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "login_box";
                  settings = {
                    background_color = "surface_container";
                    background_opacity = 1.0;
                    background_radius = 12.0;
                    center_password_text = true;
                    input_opacity = 1.0;
                    input_radius = 6.0;
                    layout = "regular";
                    show_caps_lock = true;
                    show_keyboard_layout = true;
                    show_login_button = true;
                    show_media = true;
                    show_session_buttons = true;
                    show_unlock_hint = false;
                    show_weather = true;
                  };
                };
                lockscreen-widget-0000000000000001 = {
                  box_height = 0.0;
                  box_width = 0.0;
                  cx = 2480.0;
                  cy = 48.0;
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
                lockscreen-widget-0000000000000002 = {
                  box_height = 96.0;
                  box_width = 672.0;
                  cx = 1264.6;
                  cy = 1231.7;
                  output = out;
                  placement_height = 1440.0;
                  placement_width = 2560.0;
                  rotation = 0.0;
                  type = "audio_visualizer";
                  settings = {
                    background = false;
                    bands = 32;
                    show_when_idle = true;
                  };
                };
              };
            };
          };
    };
}

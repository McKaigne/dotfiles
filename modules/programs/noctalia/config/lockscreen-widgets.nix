{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/42-lockscreen-widgets.toml".source = (pkgs.formats.toml {}).generate "42-lockscreen-widgets.toml" {
      "lockscreen_widgets" = {
        "enabled" = false;
        "schema_version" = 2;
        "widget_order" = [
          "lockscreen-login-box@DP-1"
        ];
        "grid" = {
          "cell_size" = 16;
          "major_interval" = 4;
          "visible" = true;
        };
        "widget" = {
          "lockscreen-login-box@DP-1" = {
            "box_height" = 196.0;
            "box_width" = 810.0;
            "cx" = 960.0;
            "cy" = 898.0;
            "output" = "DP-1";
            "placement_height" = 1080.0;
            "placement_width" = 1920.0;
            "rotation" = 0.0;
            "type" = "login_box";
            "settings" = {
              "background_color" = "surface_container";
              "background_opacity" = 0.88;
              "background_radius" = 12.0;
              "center_password_text" = false;
              "input_opacity" = 1.0;
              "input_radius" = 6.0;
              "layout" = "regular";
              "show_caps_lock" = true;
              "show_keyboard_layout" = true;
              "show_login_button" = true;
              "show_media" = true;
              "show_session_buttons" = true;
              "show_unlock_hint" = true;
              "show_weather" = true;
            };
          };
        };
      };
    };
  };
}

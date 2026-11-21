let
  style = import ../../appearance/_style.nix;
in {
  flake.modules.homeManager."desktop-umbriel" = {config, ...}: {
    programs.umbriel.settings = {
      general.show_cheatsheet = false;

      scratchpad = [
        {name = "terminal";}
        {name = "music";}
      ];

      environment = {
        PROTON_ENABLE_WAYLAND = "1";
        DXVK_HDR = "1";
        XCURSOR_THEME = config.workstation.cursor.theme;
        XCURSOR_SIZE = "24";
      };

      colors = {
        shadow = "#00FFFFAA";
      };

      appearance = {
        prefer_no_csd = true;
        # Borderless: focus shows through dimming, not a frame.
        border_width = 0;
        outer_border_width = 0;
        corner_radius = style.radius;
        title_bar = {
          mode = "off";
        };

        shadow = {
          enabled = false;
          softness = 0;
          offset_x = 5;
          offset_y = 5;
        };

        blur = {
          enabled = true;
          inherit (style.blur) passes radius;
          noise = 0.02;
          brightness = 0.9;
          contrast = 0.9;
          saturation = 1.1;
          # One shared blur of the wallpaper: uniform frosted glass everywhere.
          optimized = true;
        };
      };

      hot_corners.bottom_left = {
        enabled = true;
        delay_ms = 500;
        action = "overview-toggle";
      };
    };

    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "Umbriel";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Umbriel";
    };
  };
}

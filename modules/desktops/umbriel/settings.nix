{
  flake.modules.homeManager."desktop-umbriel" =
    { config, lib, ... }:
    let
      displayCfg = config.workstation.display;
    in
    {
      programs.umbriel.settings = {
        general.show_cheatsheet = false;

        scratchpad = [
          { name = "terminal"; }
          { name = "music"; }
        ];

        output.${displayCfg.output} = {
          position = [ 0 0 ];
          scale = builtins.fromJSON displayCfg.scale;
          transform = "normal";
          vrr = "disabled";
          hdr = "auto";
          workspaces = 9;
        }
        // lib.optionalAttrs (displayCfg.mode != null) {
          mode = displayCfg.mode;
        };

        environment = {
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          QT_QPA_PLATFORM = "wayland";
          QT_QPA_PLATFORMTHEME = "qt5ct";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
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
          border_width = 2;
          outer_border_width = 0;
          corner_radius = 12;
          title_bar = {
            mode = "forced";
            font = "Maple Mono NF 10";
          };

          shadow = {
            enabled = false;
            softness = 0;
            offset_x = 5;
            offset_y = 5;
          };

          blur = {
            enabled = false;
            passes = 3;
            radius = 5;
            noise = 0.0;
            brightness = 0.9;
            contrast = 0.9;
            saturation = 1.1;
            optimized = false;
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

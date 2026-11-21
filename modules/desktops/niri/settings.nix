{
  flake.modules.homeManager.desktop-niri =
    { config, lib, ... }:
    let
      displayCfg = config.workstation.display;
      parseMode =
        modeStr:
        let
          parts = lib.splitString "@" modeStr;
          res = lib.splitString "x" (builtins.elemAt parts 0);
        in
        {
          width = lib.toInt (builtins.elemAt res 0);
          height = lib.toInt (builtins.elemAt res 1);
          refresh = builtins.fromJSON (builtins.elemAt parts 1);
        };
    in
    {
      programs.niri.settings = {
        prefer-no-csd = true;
        screenshot-path = null;
        hotkey-overlay.skip-at-startup = true;

        gestures.hot-corners.enable = false;

        outputs.${displayCfg.output} = {
          scale = builtins.fromJSON displayCfg.scale;
        }
        // lib.optionalAttrs (displayCfg.mode != null) {
          mode = parseMode displayCfg.mode;
        };

        workspaces = {
          one = { };
          two = { };
          three = { };
          four = { };
          five = { };
          six = { };
          seven = { };
          eight = { };
          nine = { };
        };

        layout = {
          gaps = 8;
          center-focused-column = "on-overflow";
          default-column-width.proportion = 0.5;

          preset-column-widths = [
            { proportion = 0.33333; }
            { proportion = 0.5; }
            { proportion = 0.66667; }
            { proportion = 1.0; }
          ];

          focus-ring.enable = false;

          border = {
            enable = true;
            width = 2;
          };
        };

        overview = {
          zoom = 0.5;
          workspace-shadow = {
            softness = 40;
            spread = 10;
            offset = {
              x = 0;
              y = 10;
            };
            color = "#00000060";
          };
        };

        input = {
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
          warp-mouse-to-focus = {
            enable = true;
            mode = "center-xy";
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
            accel-speed = 0.2;
            accel-profile = "adaptive";
            scroll-method = "two-finger";
            click-method = "clickfinger";
            tap-button-map = "left-right-middle";
          };
        };

        cursor = {
          theme = config.workstation.cursor.theme;
          size = 24;
          hide-when-typing = true;
        };

        environment = {
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          QT_QPA_PLATFORM = "wayland";
          QT_QPA_PLATFORMTHEME = "qt5ct";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "niri";
          XCURSOR_SIZE = "24";
          XCURSOR_THEME = config.workstation.cursor.theme;
        };
      };
    };
}

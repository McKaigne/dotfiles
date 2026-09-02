{ inputs, self, ... }: {
  # 1. NixOS System Module
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };

  # 2. Wrapper module with valid KDL node structures
  flake.wrappersModules.niri = { config, lib, pkgs, ... }: {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "ghostty";
    };

    config = {
      settings =
        let
          noctaliaExe = lib.getExe self.packages.${config.pkgs.stdenv.hostPlatform.system}.noctalia-shell;
        in
        {
          prefer-no-csd = { };

          input = {
            focus-follows-mouse = { };
            keyboard = {
              xkb = {
                layout = "us";
                options = "caps:escape";
              };
              repeat-rate = 40;
              repeat-delay = 250;
            };
            touchpad = {
              natural-scroll = { };
              tap = { };
            };
            mouse = {
              accel-profile = "flat";
            };
          };

          binds = {
            # Terminal & Core Apps
            "Mod+Return".spawn = config.terminal;
            "Mod+W".spawn-sh = "${inputs.helium.packages.${config.pkgs.stdenv.hostPlatform.system}.default}/bin/helium";
            "Mod+E".spawn-sh = "emacsclient -c -a 'emacs'";

            # Window Actions
            "Mod+Q".close-window = { };
            "Mod+F".maximize-column = { };
            "Mod+G".fullscreen-window = { };
            "Mod+Shift+F".toggle-window-floating = { };
            "Mod+C".center-column = { };

            # Vim Navigation (HJKL)
            "Mod+H".focus-column-left = { };
            "Mod+L".focus-column-right = { };
            "Mod+K".focus-window-up = { };
            "Mod+J".focus-window-down = { };

            # Arrow Navigation
            "Mod+Left".focus-column-left = { };
            "Mod+Right".focus-column-right = { };
            "Mod+Up".focus-window-up = { };
            "Mod+Down".focus-window-down = { };

            # Move Columns (Vim Keys & Arrows)
            "Mod+Shift+H".move-column-left = { };
            "Mod+Shift+L".move-column-right = { };
            "Mod+Shift+K".move-window-up = { };
            "Mod+Shift+J".move-window-down = { };

            "Mod+Shift+Left".move-column-left = { };
            "Mod+Shift+Right".move-column-right = { };
            "Mod+Shift+Up".move-window-up = { };
            "Mod+Shift+Down".move-window-down = { };

            # Workspaces 0-9
            "Mod+1".focus-workspace = "w0";
            "Mod+2".focus-workspace = "w1";
            "Mod+3".focus-workspace = "w2";
            "Mod+4".focus-workspace = "w3";
            "Mod+5".focus-workspace = "w4";
            "Mod+6".focus-workspace = "w5";
            "Mod+7".focus-workspace = "w6";
            "Mod+8".focus-workspace = "w7";
            "Mod+9".focus-workspace = "w8";
            "Mod+0".focus-workspace = "w9";

            "Mod+Shift+1".move-column-to-workspace = "w0";
            "Mod+Shift+2".move-column-to-workspace = "w1";
            "Mod+Shift+3".move-column-to-workspace = "w2";
            "Mod+Shift+4".move-column-to-workspace = "w3";
            "Mod+Shift+5".move-column-to-workspace = "w4";
            "Mod+Shift+6".move-column-to-workspace = "w5";
            "Mod+Shift+7".move-column-to-workspace = "w6";
            "Mod+Shift+8".move-column-to-workspace = "w7";
            "Mod+Shift+9".move-column-to-workspace = "w8";
            "Mod+Shift+0".move-column-to-workspace = "w9";

            # Noctalia Launcher & Controls
            "Mod+S".spawn-sh = "${noctaliaExe} ipc call launcher toggle";

            # Audio Controls
            "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";

            # Column & Window Resizing
            "Mod+Ctrl+H".set-column-width = "-5%";
            "Mod+Ctrl+L".set-column-width = "+5%";
            "Mod+Ctrl+J".set-window-height = "-5%";
            "Mod+Ctrl+K".set-window-height = "+5%";

            # Mouse Wheel Workspace Scrolling
            "Mod+WheelScrollDown".focus-column-left = { };
            "Mod+WheelScrollUp".focus-column-right = { };
            "Mod+Ctrl+WheelScrollDown".focus-workspace-down = { };
            "Mod+Ctrl+WheelScrollUp".focus-workspace-up = { };

            # Screenshots
            "Mod+Ctrl+S".spawn-sh = "${lib.getExe config.pkgs.grim} -l 0 - | ${config.pkgs.wl-clipboard}/bin/wl-copy";
            "Mod+Shift+S".spawn-sh = lib.getExe (config.pkgs.writeShellApplication {
              name = "screenshot";
              text = ''
                ${lib.getExe config.pkgs.grim} -g "$(${lib.getExe config.pkgs.slurp} -w 0)" - | ${config.pkgs.wl-clipboard}/bin/wl-copy
              '';
            });
          };

          layout = {
            gaps = 8;
            focus-ring = {
              width = 2;
              active-color = "#74c7ec";
            };
          };

          workspaces =
            let
              ws = { layout.gaps = 8; };
            in
            {
              "w0" = ws;
              "w1" = ws;
              "w2" = ws;
              "w3" = ws;
              "w4" = ws;
              "w5" = ws;
              "w6" = ws;
              "w7" = ws;
              "w8" = ws;
              "w9" = ws;
            };

          xwayland-satellite.path = lib.getExe config.pkgs.xwayland-satellite;

          spawn-at-startup = [
            noctaliaExe
          ];
        };
    };
  };

  # 3. Build the wrapped Niri package
  perSystem = { pkgs, ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [ self.wrappersModules.niri ];
    };
  };
}

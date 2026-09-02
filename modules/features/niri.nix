{ inputs, self, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };

  flake.wrappersModules.niri = { config, lib, pkgs, ... }: {
    options.terminal = lib.mkOption {
      type = lib.types.str;
      default = "ghostty";
    };

    config = {
      settings =
        let
          noctaliaExe = lib.getExe self.packages.${config.pkgs.stdenv.hostPlatform.system}.noctalia-shell;
          heliumExe = "${inputs.helium.packages.${config.pkgs.stdenv.hostPlatform.system}.default}/bin/helium";
        in
        {
          prefer-no-csd = { };
          hotkey-overlay.skip-at-startup = { };

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
            # -----------------------------------------------------------------
            # 1. Shell & Launchers
            # -----------------------------------------------------------------
            "Mod+Space".spawn-sh = "${noctaliaExe} ipc call launcher toggle || noctalia msg panel-toggle launcher";
            "Mod+Tab".spawn-sh = "${noctaliaExe} ipc call overview toggle || noctalia msg panel-toggle overview";
            "Mod+A".spawn-sh = "${noctaliaExe} ipc call left-sidebar toggle || noctalia msg panel-toggle left-sidebar";
            "Mod+N".spawn-sh = "${noctaliaExe} ipc call control-center toggle || noctalia msg panel-toggle control-center";
            "Mod+Alt+B".spawn-sh = "${noctaliaExe} ipc call bar toggle || noctalia msg bar-toggle";
            "Ctrl+Alt+Delete".spawn-sh = "${noctaliaExe} ipc call session-menu toggle || noctalia msg panel-toggle session-menu";

            # -----------------------------------------------------------------
            # 2. Applications
            # -----------------------------------------------------------------
            "Mod+Return".spawn = config.terminal;
            "Mod+T".spawn = config.terminal;
            "Mod+E".spawn-sh = "ghostty -e ${pkgs.yazi}/bin/yazi";
            "Mod+W".spawn-sh = heliumExe;
            "Mod+C".spawn-sh = "emacsclient -c -a 'emacs'";
            "Mod+X".spawn-sh = "ghostty -e nvim";
            "Mod+I".spawn-sh = "${noctaliaExe} ipc call settings toggle || noctalia msg settings-toggle";
            "Ctrl+Shift+Escape".spawn-sh = "ghostty -e ${pkgs.btop}/bin/btop";

            # -----------------------------------------------------------------
            # 3. Window Actions
            # -----------------------------------------------------------------
            "Mod+Q".close-window = { };
            "Mod+Alt+Space".toggle-window-floating = { };
            "Mod+Shift+F".toggle-window-floating = { };
            "Mod+F".maximize-column = { };
            "Mod+Alt+C".center-column = { };

            # Focus Navigation (Vim HJKL & Arrows)
            "Mod+H".focus-column-left = { };
            "Mod+L".focus-column-right = { };
            "Mod+K".focus-window-up = { };
            "Mod+J".focus-window-down = { };

            "Mod+Left".focus-column-left = { };
            "Mod+Right".focus-column-right = { };
            "Mod+Up".focus-window-up = { };
            "Mod+Down".focus-window-down = { };

            # Move Columns (Vim HJKL & Arrows)
            "Mod+Shift+H".move-column-left = { };
            "Mod+Shift+L".move-column-right = { };
            "Mod+Shift+K".move-window-up = { };
            "Mod+Shift+J".move-window-down = { };

            "Mod+Shift+Left".move-column-left = { };
            "Mod+Shift+Right".move-column-right = { };
            "Mod+Shift+Up".move-window-up = { };
            "Mod+Shift+Down".move-window-down = { };

            # Resize
            "Mod+Ctrl+H".set-column-width = "-5%";
            "Mod+Ctrl+L".set-column-width = "+5%";
            "Mod+Ctrl+J".set-window-height = "-5%";
            "Mod+Ctrl+K".set-window-height = "+5%";

            # -----------------------------------------------------------------
            # 4. Workspaces (0-9 & Page Up / Page Down)
            # -----------------------------------------------------------------
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

            # Page Up / Down Workspace Navigation
            "Mod+Page_Down".focus-workspace-down = { };
            "Mod+Page_Up".focus-workspace-up = { };
            "Mod+Shift+Page_Down".move-column-to-workspace-down = { };
            "Mod+Shift+Page_Up".move-column-to-workspace-up = { };

            # Wheel navigation
            "Mod+WheelScrollDown".focus-column-left = { };
            "Mod+WheelScrollUp".focus-column-right = { };
            "Mod+Ctrl+WheelScrollDown".focus-workspace-down = { };
            "Mod+Ctrl+WheelScrollUp".focus-workspace-up = { };

            # -----------------------------------------------------------------
            # 5. Utilities & Screenshots
            # -----------------------------------------------------------------
            "Mod+V".spawn-sh = "${noctaliaExe} ipc call clipboard toggle || noctalia msg panel-toggle clipboard";

            "Mod+Shift+S".spawn-sh = lib.getExe (config.pkgs.writeShellApplication {
              name = "screenshot-area";
              runtimeInputs = with config.pkgs; [ grim slurp wl-clipboard ];
              text = ''
                grim -g "$(slurp -w 0)" - | wl-copy
              '';
            });

            "Print".spawn-sh = "${lib.getExe config.pkgs.grim} -l 0 - | ${config.pkgs.wl-clipboard}/bin/wl-copy";

            # -----------------------------------------------------------------
            # 6. Media & Hardware
            # -----------------------------------------------------------------
            "XF86MonBrightnessUp".spawn-sh = "brightnessctl s 5%+";
            "XF86MonBrightnessDown".spawn-sh = "brightnessctl s 5%-";
            "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 2%+";
            "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 2%-";
            "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "Mod+Shift+M".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "Mod+Shift+P".spawn-sh = "playerctl play-pause";
            "Mod+Shift+N".spawn-sh = "playerctl next";
            "Mod+Shift+B".spawn-sh = "playerctl previous";

            # -----------------------------------------------------------------
            # 7. Session
            # -----------------------------------------------------------------
            "Mod+Alt+L".spawn-sh = "loginctl lock-session";
            "Mod+Alt+Shift+L".spawn-sh = "systemctl suspend || loginctl suspend";
            "Ctrl+Shift+Alt+Mod+Delete".spawn-sh = "systemctl poweroff || loginctl poweroff";
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

  perSystem = { pkgs, ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [ self.wrappersModules.niri ];
    };
  };
}


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

          cursor = {
            xcursor-theme = "Bibata-Modern-Classic";
            xcursor-size = 16;
          };

          # -----------------------------------------------------------------
          # 1. Hardware Input & Multi-Touch Gestures
          # -----------------------------------------------------------------
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
              tap = { };
              natural-scroll = { };
              dwt = { };
              accel-speed = 0.2;
              accel-profile = "adaptive";
              scroll-method = "two-finger";
            };

            mouse = {
              accel-profile = "flat";
            };
          };

          # -----------------------------------------------------------------
          # 2. Keybindings & Actions
          # -----------------------------------------------------------------
          binds = {
            # ===============================================================
            # A. NOCTALIA SHELL & CONTROL CENTER
            # ===============================================================
            # Launcher (SUPER + D)
            "Mod+D".spawn-sh = "${noctaliaExe} ipc call launcher toggle || noctalia msg panel-toggle launcher";

            # Control Center & Notifications (SUPER + N)
            "Mod+N".spawn-sh = "${noctaliaExe} ipc call controlCenter toggle || ${noctaliaExe} ipc call control-center toggle || noctalia msg panel-toggle control-center";

            # Left Sidebar (SUPER + A)
            "Mod+A".spawn-sh = "${noctaliaExe} ipc call sidebarLeft toggle || ${noctaliaExe} ipc call left-sidebar toggle || noctalia msg panel-toggle left-sidebar";

            # Media Controls (SUPER + M)
            "Mod+M".spawn-sh = "${noctaliaExe} ipc call media toggle || noctalia msg panel-toggle media";

            # Top Bar Visibility (SUPER + Alt + B)
            "Mod+Alt+B".spawn-sh = "${noctaliaExe} ipc call bar toggle || noctalia msg bar-toggle";

            # Clipboard Manager (SUPER + V)
            "Mod+V".spawn-sh = "${noctaliaExe} ipc call clipboard toggle || noctalia msg panel-toggle clipboard";

            # Noctalia Settings (SUPER + I)
            "Mod+I".spawn-sh = "${noctaliaExe} ipc call settings toggle || noctalia msg settings-toggle";

            # Session / Power Menu (Ctrl + Alt + Delete)
            "Ctrl+Alt+Delete".spawn-sh = "${noctaliaExe} ipc call sessionMenu toggle || ${noctaliaExe} ipc call session-menu toggle || noctalia msg panel-toggle session-menu";

            # ===============================================================
            # B. NATIVE NIRI OVERVIEW & WORKSPACES
            # ===============================================================
            # Native Niri Zoomed-Out Overview (SUPER + Tab)
            "Mod+Tab".toggle-overview = { };

            # Direct Workspaces (0-9)
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

            # Workspace Cycling (Page Up = Higher workspace, Page Down = Lower)
            "Mod+Page_Down".focus-workspace-down = { };
            "Mod+Page_Up".focus-workspace-up = { };
            "Mod+Shift+Page_Down".move-column-to-workspace-down = { };
            "Mod+Shift+Page_Up".move-column-to-workspace-up = { };

            # Reorder Workspaces up/down
            "Mod+Ctrl+Page_Down".move-workspace-down = { };
            "Mod+Ctrl+Page_Up".move-workspace-up = { };

            # ===============================================================
            # C. APPLICATIONS
            # ===============================================================
            "Mod+Return".spawn = config.terminal;
            "Mod+T".spawn = config.terminal;
            "Mod+E".spawn-sh = "ghostty -e ${pkgs.yazi}/bin/yazi";
            "Mod+W".spawn-sh = heliumExe;
            "Mod+C".spawn-sh = "emacsclient -c -a 'emacs'";
            "Mod+X".spawn-sh = "ghostty -e nvim";
            "Ctrl+Shift+Escape".spawn-sh = "ghostty -e ${pkgs.btop}/bin/btop";

            # ===============================================================
            # D. WINDOW ACTIONS & COLUMN STACKING
            # ===============================================================
            "Mod+Q".close-window = { };
            "Mod+F".maximize-column = { };
            "Mod+Shift+F".toggle-window-floating = { };
            "Mod+Alt+Space".toggle-window-floating = { };
            "Mod+Alt+C".center-column = { };

            # Stacking: Consume into column & Expel out of column
            "Mod+Comma".consume-window-into-column = { };
            "Mod+Period".expel-window-from-column = { };

            # Width presets (33%, 50%, 66%, 100%) & Height reset
            "Mod+R".switch-preset-column-width = { };
            "Mod+Shift+R".reset-window-height = { };

            # ===============================================================
            # E. FOCUS & NAVIGATION (Vim HJKL & Arrows)
            # ===============================================================
            "Mod+H".focus-column-left = { };
            "Mod+L".focus-column-right = { };
            "Mod+K".focus-window-up = { };
            "Mod+J".focus-window-down = { };

            "Mod+Left".focus-column-left = { };
            "Mod+Right".focus-column-right = { };
            "Mod+Up".focus-window-up = { };
            "Mod+Down".focus-window-down = { };

            # First / Last Column in ribbon
            "Mod+Home".focus-column-first = { };
            "Mod+End".focus-column-last = { };

            # Move Columns in Ribbon
            "Mod+Shift+H".move-column-left = { };
            "Mod+Shift+L".move-column-right = { };
            "Mod+Shift+K".move-window-up = { };
            "Mod+Shift+J".move-window-down = { };

            "Mod+Shift+Left".move-column-left = { };
            "Mod+Shift+Right".move-column-right = { };
            "Mod+Shift+Up".move-window-up = { };
            "Mod+Shift+Down".move-window-down = { };

            "Mod+Shift+Home".move-column-to-first = { };
            "Mod+Shift+End".move-column-to-last = { };

            # Manual Resizing
            "Mod+Ctrl+H".set-column-width = "-5%";
            "Mod+Ctrl+L".set-column-width = "+5%";
            "Mod+Ctrl+J".set-window-height = "-5%";
            "Mod+Ctrl+K".set-window-height = "+5%";

            # ===============================================================
            # F. MOUSE & 2-FINGER TRACKPAD SCROLLING
            # ===============================================================
            "Mod+WheelScrollDown".focus-column-left = { };
            "Mod+WheelScrollUp".focus-column-right = { };
            "Mod+Ctrl+WheelScrollDown".focus-workspace-down = { };
            "Mod+Ctrl+WheelScrollUp".focus-workspace-up = { };

            "Mod+TouchpadScrollDown".focus-column-left = { };
            "Mod+TouchpadScrollUp".focus-column-right = { };
            "Mod+TouchpadScrollRight".focus-column-right = { };
            "Mod+TouchpadScrollLeft".focus-column-left = { };
            "Mod+Ctrl+TouchpadScrollDown".focus-workspace-down = { };
            "Mod+Ctrl+TouchpadScrollUp".focus-workspace-up = { };

            # ===============================================================
            # G. SCREENSHOTS & HARDWARE KEYS
            # ===============================================================
            "Mod+Shift+S".spawn-sh = lib.getExe (config.pkgs.writeShellApplication {
              name = "screenshot-area";
              runtimeInputs = with config.pkgs; [ grim slurp wl-clipboard ];
              text = ''
                grim -g "$(slurp -w 0)" - | wl-copy
              '';
            });

            "Print".spawn-sh = "${lib.getExe config.pkgs.grim} -l 0 - | ${config.pkgs.wl-clipboard}/bin/wl-copy";

            "XF86MonBrightnessUp".spawn-sh = "brightnessctl s 5%+";
            "XF86MonBrightnessDown".spawn-sh = "brightnessctl s 5%-";
            "XF86AudioRaiseVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 2%+";
            "XF86AudioLowerVolume".spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 2%-";
            "XF86AudioMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            "Mod+Shift+M".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

            "XF86AudioMicMute".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
            "Mod+Alt+M".spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

            "Mod+Shift+P".spawn-sh = "playerctl play-pause";
            "XF86AudioPlay".spawn-sh = "playerctl play-pause";
            "XF86AudioPause".spawn-sh = "playerctl play-pause";
            "Mod+Shift+N".spawn-sh = "playerctl next";
            "XF86AudioNext".spawn-sh = "playerctl next";
            "Mod+Shift+B".spawn-sh = "playerctl previous";
            "XF86AudioPrev".spawn-sh = "playerctl previous";

            # ===============================================================
            # H. SESSION & POWER
            # ===============================================================
            "Mod+Alt+L".spawn-sh = "${lib.getExe pkgs.hyprlock}";
            "Mod+Alt+Shift+L".spawn-sh = "${lib.getExe pkgs.hyprlock} & sleep 0.5 && systemctl suspend";
            "Ctrl+Shift+Alt+Mod+Delete".spawn-sh = "systemctl poweroff || loginctl poweroff";
          };

          layout = {
            gaps = 8;
            preset-column-widths = [
              { proportion = 0.33333; }
              { proportion = 0.5; }
              { proportion = 0.66667; }
              { proportion = 1.0; }
            ];
            default-column-width = { proportion = 0.5; };
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

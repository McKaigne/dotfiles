{
  flake.modules.homeManager.desktop-niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.lib.niri.actions) spawn;

      noctalia = lib.getExe pkgs.noctalia;
      kitty = lib.getExe pkgs.kitty;
      pcmanfm = lib.getExe pkgs.pcmanfm;
      librewolf = lib.getExe pkgs.librewolf;
      helium = lib.getExe pkgs.helium;
      wpctl = "${pkgs.wireplumber}/bin/wpctl";
      playerctl = lib.getExe pkgs.playerctl;
      wtype = lib.getExe pkgs.wtype;
      pavucontrol = lib.getExe pkgs.pavucontrol;
      bitwarden = "${pkgs.bitwarden-desktop}/bin/bitwarden";

      screenshotArea = pkgs.writeShellScript "screenshot-area" ''
        set -euo pipefail
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      screenshotFull = pkgs.writeShellScript "screenshot-full" ''
        set -euo pipefail
        ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      brightnessUp = pkgs.writeShellScript "brightness-up" ''
        set -euo pipefail
        if command -v noctalia >/dev/null 2>&1 && noctalia msg ping >/dev/null 2>&1; then
          noctalia msg brightness-up 5
        elif [ -d /sys/class/backlight ] && [ -n "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl set +5%
        else
          ${pkgs.ddcutil}/bin/ddcutil setvcp 10 + 5 2>/dev/null || true
        fi
      '';

      brightnessDown = pkgs.writeShellScript "brightness-down" ''
        set -euo pipefail
        if command -v noctalia >/dev/null 2>&1 && noctalia msg ping >/dev/null 2>&1; then
          noctalia msg brightness-down 5
        elif [ -d /sys/class/backlight ] && [ -n "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl get)
          max=$(${pkgs.brightnessctl}/bin/brightnessctl max)
          new=$((curr - max * 5 / 100))
          if [ "$new" -lt "$((max * 5 / 100))" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl set 5%
          else
            ${pkgs.brightnessctl}/bin/brightnessctl set 5%-
          fi
        else
          ${pkgs.ddcutil}/bin/ddcutil setvcp 10 - 5 2>/dev/null || true
        fi
      '';
    in
    {
      programs.niri.settings.binds = with config.lib.niri.actions; {
        "Mod+Space" = {
          hotkey-overlay.title = "Launcher: Noctalia App Runner";
          action = spawn noctalia "msg" "panel-toggle" "launcher";
        };
        "Mod+Return" = {
          hotkey-overlay.title = "Fill Screen (Maximize Column Width)";
          action = maximize-column;
        };
        "Mod+Shift+Return" = {
          hotkey-overlay.title = "Fullscreen Window";
          action = fullscreen-window;
        };
        "Mod+Ctrl+Return" = {
          hotkey-overlay.title = "Toggle Window Floating";
          action = toggle-window-floating;
        };
        "Mod+Alt+Return" = {
          hotkey-overlay.title = "Switch Focus Floating/Tiling";
          action = switch-focus-between-floating-and-tiling;
        };
        "Mod+Tab" = {
          hotkey-overlay.title = "Overview: Niri Workspace View";
          action = toggle-overview;
        };
        "Mod+BackSpace" = {
          hotkey-overlay.title = "Close Focused Window";
          action = close-window;
        };

        "Mod+C" = {
          hotkey-overlay.title = "Universal Copy";
          action = spawn wtype "-M" "ctrl" "-k" "Insert";
        };
        "Mod+V" = {
          hotkey-overlay.title = "Universal Paste";
          action = spawn wtype "-M" "shift" "-k" "Insert";
        };

        "Mod+S" = {
          hotkey-overlay.title = "Files: PCManFM File Manager";
          action = spawn pcmanfm;
        };
        "Mod+D" = {
          hotkey-overlay.title = "Browser: LibreWolf";
          action = spawn librewolf;
        };
        "Mod+Shift+D" = {
          hotkey-overlay.title = "Browser: Helium";
          action = spawn helium;
        };
        "Mod+Ctrl+D" = {
          hotkey-overlay.title = "Browser: LibreWolf Private";
          action = spawn librewolf "--private-window";
        };
        "Mod+F" = {
          hotkey-overlay.title = "Terminal: Kitty";
          action = spawn kitty;
        };
        "Mod+Shift+F" = {
          hotkey-overlay.title = "Zellij: Session & Project Manager";
          action = spawn kitty "--title" "Zellij Session Manager" "-e" "zsession";
        };

        "Mod+W" = {
          hotkey-overlay.title = "Wallpaper: Noctalia Selector";
          action = spawn noctalia "msg" "panel-toggle" "wallpaper";
        };
        "Mod+Shift+W" = {
          hotkey-overlay.title = "Bar: Toggle Noctalia Top Bar";
          action = spawn noctalia "msg" "bar-toggle";
        };
        "Mod+T" = {
          hotkey-overlay.title = "Snip: Area Screenshot to Clipboard";
          action = spawn "${screenshotArea}";
        };
        "Mod+Shift+T" = {
          hotkey-overlay.title = "Snip: Fullscreen Screenshot";
          action = spawn "${screenshotFull}";
        };
        "Mod+B" = {
          hotkey-overlay.title = "Security: Bitwarden Desktop";
          action = spawn bitwarden;
        };
        "Mod+Shift+B" = {
          hotkey-overlay.title = "Security: Bitwarden Noctalia Panel";
          action = spawn noctalia "msg" "panel-toggle" "noctalia/bitwarden:vault";
        };
        "Mod+Ctrl+B" = {
          hotkey-overlay.title = "Bluetooth: Noctalia Panel";
          action = spawn noctalia "msg" "panel-toggle" "bluetooth";
        };

        "Mod+Y" = {
          hotkey-overlay.title = "Clipboard: History Panel";
          action = spawn noctalia "msg" "panel-toggle" "clipboard";
        };
        "Mod+U" = {
          hotkey-overlay.title = "Keyviz: Toggle Key Visualizer HUD";
          action = spawn noctalia "msg" "panel-toggle" "h-jangra/keyviz:overlay";
        };
        "Mod+I" = {
          hotkey-overlay.title = "Lid Guard: Toggle Sleep Inhibitor";
          action =
            spawn noctalia "msg" "plugin" "8bury/lid-guard:lid-guard-service" "all"
              "toggle";
        };
        "Mod+O" = {
          hotkey-overlay.title = "Capture: OBS Studio";
          action = spawn "obs";
        };
        "Mod+Shift+O" = {
          hotkey-overlay.title = "Capture: OBS Control Panel";
          action = spawn noctalia "msg" "panel-toggle" "ayagmar/obs-control:panel";
        };
        "Mod+P" = {
          hotkey-overlay.title = "Audio: Pavucontrol Mixer";
          action = spawn pavucontrol;
        };
        "Mod+Shift+P" = {
          hotkey-overlay.title = "Audio: EasyEffects";
          action = spawn "easyeffects";
        };

        "Mod+N" = {
          hotkey-overlay.title = "Notices: Notification Center Panel";
          action = spawn noctalia "msg" "panel-toggle" "notifications";
        };
        "Mod+Shift+N" = {
          hotkey-overlay.title = "Notices: Clear Notice History";
          action = spawn noctalia "msg" "notification-clear-all";
        };
        "Mod+Ctrl+N" = {
          hotkey-overlay.title = "Notices: Dismiss Active Notice";
          action = spawn noctalia "msg" "notification-clear-active";
        };
        "Mod+M" = {
          hotkey-overlay.title = "Audio: Toggle Mic Mute";
          action = spawn wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
        };
        "Mod+Shift+M" = {
          hotkey-overlay.title = "Media: Play / Pause";
          action = spawn playerctl "play-pause";
        };

        "Mod+Semicolon" = {
          hotkey-overlay.title = "Session: Lock Screen";
          action = spawn noctalia "msg" "session" "lock";
        };
        "Mod+Shift+Semicolon" = {
          hotkey-overlay.title = "Session: Noctalia Power Menu";
          action = spawn noctalia "msg" "panel-toggle" "session";
        };
        "Mod+Ctrl+Semicolon" = {
          hotkey-overlay.title = "Monitors: Turn Off Displays";
          action = power-off-monitors;
        };

        "Mod+Comma" = {
          hotkey-overlay.title = "Settings: Noctalia Settings GUI";
          action = spawn noctalia "msg" "settings-toggle";
        };
        "Mod+Period" = {
          hotkey-overlay.title = "Control: Noctalia Control Center";
          action = spawn noctalia "msg" "panel-toggle" "control-center";
        };
        "Mod+Slash" = {
          hotkey-overlay.title = "Cheatsheet: Keybind Cheatsheet";
          action =
            spawn noctalia "msg" "panel-toggle"
              "kenn/keybind-cheatsheet:cheatsheet";
        };

        "Mod+Escape" = {
          hotkey-overlay.title = "Session: Noctalia Power Menu";
          action = spawn noctalia "msg" "panel-toggle" "session";
        };
        "Mod+Shift+Escape" = {
          hotkey-overlay.title = "Session: Lock Screen";
          action = spawn noctalia "msg" "session" "lock";
        };
        "Mod+Ctrl+Escape" = {
          hotkey-overlay.title = "Monitors: Turn Off Displays";
          action = power-off-monitors;
        };

        "Mod+Alt+Left".action = focus-monitor-left;
        "Mod+Alt+Right".action = focus-monitor-right;
        "Mod+Alt+Shift+Left".action = move-column-to-monitor-left;
        "Mod+Alt+Shift+Right".action = move-column-to-monitor-right;
        "Mod+Left".action = focus-column-left;
        "Mod+Right".action = focus-column-right;
        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Right".action = move-column-right;
        "Mod+Ctrl+Left".action.set-column-width = [ "-5%" ];
        "Mod+Ctrl+Right".action.set-column-width = [ "+5%" ];
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Shift+Down".action = move-window-down;
        "Mod+Shift+Up".action = move-window-up;
        "Mod+Ctrl+Down".action.set-window-height = [ "-5%" ];
        "Mod+Ctrl+Up".action.set-window-height = [ "+5%" ];

        "Mod+Alt+H".action = focus-monitor-left;
        "Mod+Alt+L".action = focus-monitor-right;
        "Mod+Alt+Shift+H".action = move-column-to-monitor-left;
        "Mod+Alt+Shift+L".action = move-column-to-monitor-right;
        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Ctrl+H".action.set-column-width = [ "-5%" ];
        "Mod+Ctrl+L".action.set-column-width = [ "+5%" ];
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;
        "Mod+Ctrl+J".action.set-window-height = [ "-5%" ];
        "Mod+Ctrl+K".action.set-window-height = [ "+5%" ];

        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
        "Mod+Shift+Page_Up".action = move-column-to-workspace-up;

        "Mod+Home".action = consume-or-expel-window-left;
        "Mod+End".action = consume-or-expel-window-right;
        "Mod+Delete".action = expel-window-from-column;

        "Mod+1".action = focus-workspace "one";
        "Mod+2".action = focus-workspace "two";
        "Mod+3".action = focus-workspace "three";
        "Mod+4".action = focus-workspace "four";
        "Mod+5".action = focus-workspace "five";
        "Mod+6".action = focus-workspace "six";
        "Mod+7".action = focus-workspace "seven";
        "Mod+8".action = focus-workspace "eight";
        "Mod+9".action = focus-workspace "nine";
        "Mod+0".action = focus-workspace 10;

        "Mod+Shift+1".action.move-column-to-workspace = [ "one" ];
        "Mod+Shift+2".action.move-column-to-workspace = [ "two" ];
        "Mod+Shift+3".action.move-column-to-workspace = [ "three" ];
        "Mod+Shift+4".action.move-column-to-workspace = [ "four" ];
        "Mod+Shift+5".action.move-column-to-workspace = [ "five" ];
        "Mod+Shift+6".action.move-column-to-workspace = [ "six" ];
        "Mod+Shift+7".action.move-column-to-workspace = [ "seven" ];
        "Mod+Shift+8".action.move-column-to-workspace = [ "eight" ];
        "Mod+Shift+9".action.move-column-to-workspace = [ "nine" ];
        "Mod+Shift+0".action.move-column-to-workspace = [ 10 ];

        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action = focus-column-right;
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action = focus-column-left;
        };

        "Print" = {
          hotkey-overlay.title = "Fullscreen Screenshot";
          action = spawn "${screenshotFull}";
        };
        "XF86MonBrightnessUp".action = spawn "${brightnessUp}";
        "XF86MonBrightnessDown".action = spawn "${brightnessDown}";
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = spawn wpctl "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%+";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = spawn wpctl "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%-";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = spawn wpctl "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = spawn wpctl "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
        };
        "XF86AudioPlay".action = spawn playerctl "play-pause";
        "XF86AudioNext".action = spawn playerctl "next";
        "XF86AudioPrev".action = spawn playerctl "previous";
      };
    };
}

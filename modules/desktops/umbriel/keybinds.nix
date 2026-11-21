{
  # CUA-style desktop binds (Windows/GNOME conventions) plus mnemonic app binds.
  # Mod is the Super/Windows key. Mod+/ shows them all.
  flake.modules.homeManager."desktop-umbriel" = {
    config,
    pkgs,
    lib,
    ...
  }: let
    browser = config.home.sessionVariables.BROWSER;
    noctalia = lib.getExe pkgs.noctalia;
    foot = "${pkgs.foot}/bin/foot";
    pcmanfm = "${pkgs.pcmanfm}/bin/pcmanfm";
    # Terminal tools open in their own foot window.
    inFoot = cmd: "spawn ${foot} -e ${cmd}";
    msg = args: "spawn ${noctalia} msg ${args}";
    whenLocked = action: {
      inherit action;
      allow_when_locked = true;
    };
  in {
    programs.umbriel.settings.keybinds =
      {
        # --- Apps (mnemonic)
        "Mod+Return" = "spawn ${foot}"; # terminal
        "Mod+T" = "spawn ${foot}"; # Terminal
        "Mod+Z" = inFoot "zellij attach --create main"; # Zellij session
        "Mod+B" = "spawn ${browser}"; # Browser (LibreWolf)
        "Mod+Shift+B" = "spawn helium"; # second Browser (Helium)
        "Mod+E" = "spawn ${pcmanfm}"; # Explorer
        "Mod+C" = inFoot "emacs"; # Code (Emacs)
        "Mod+H" = inFoot "hx"; # Helix
        "Mod+G" = inFoot "lazygit"; # Git
        "Mod+M" = inFoot "btop"; # Monitor
        "Mod+P" = "spawn bitwarden"; # Passwords
        "Mod+O" = "spawn obs"; # OBS (hyde)

        # --- Shell (Noctalia), Windows/GNOME style
        "Mod" = msg "panel-toggle launcher"; # tap Super: launcher
        "Mod+R" = msg "panel-toggle launcher"; # Run
        "Alt+Tab" = msg "window-switcher";
        "Mod+A" = msg "panel-toggle control-center"; # quick settings
        "Mod+N" = msg "panel-toggle control-center notifications";
        "Mod+V" = msg "panel-toggle clipboard"; # clipboard history
        "Mod+I" = msg "settings-toggle"; # settings
        "Mod+W" = msg "panel-toggle wallpaper";
        "Mod+L" = msg "session lock"; # Lock
        "Mod+X" = msg "panel-toggle session"; # power menu
        "Ctrl+Alt+Delete" = msg "panel-toggle session";
        "Mod+slash" = "cheatsheet-toggle";
        "Mod+F1" = "cheatsheet-toggle"; # help

        # Screenshots: Win+Shift+S snips a region; PrtSc the screen; Alt+PrtSc the window.
        "Mod+Shift+S" = msg "screenshot-region --annotate --copy-to-clipboard --no-save-to-file";
        "Print" = msg "screenshot-fullscreen --copy-to-clipboard --no-save-to-file";
        "Alt+Print" = msg "screenshot-window --copy-to-clipboard --no-save-to-file";

        # --- Windows
        "Alt+F4" = "window-close";
        "Mod+Q" = "window-close";
        "Mod+Up" = "window-toggle-maximize";
        "Mod+Down" = "window-minimize";
        "Mod+F" = "window-toggle-fullscreen";
        "Mod+F11" = "window-toggle-fullscreen";
        "Mod+Space" = "window-toggle-floating";
        "Mod+Shift+P" = "window-toggle-pinned";
        "Mod+Tab" = "overview-toggle"; # task view

        # Focus and move: arrows, like Win+arrows.
        "Mod+Left" = "window-focus-left";
        "Mod+Right" = "window-focus-right";
        "Mod+Alt+Up" = "window-focus-up";
        "Mod+Alt+Down" = "window-focus-down";
        "Mod+Shift+Left" = "column-move-left";
        "Mod+Shift+Right" = "column-move-right";
        "Mod+Shift+Up" = "window-move-up";
        "Mod+Shift+Down" = "window-move-down";

        # Width: Mod+-/= nudge, Mod+Shift+R cycles presets. Mod+[ / ] stack into a column.
        "Mod+minus" = "window-modify-primary-extent -0.1";
        "Mod+equal" = "window-modify-primary-extent 0.1";
        "Mod+Shift+R" = "window-cycle-primary-extent";
        "Mod+bracketleft" = "window-consume-left";
        "Mod+bracketright" = "window-consume-or-expel-right";

        # Quake-style terminal scratchpad.
        "Mod+grave" = "scratchpad-toggle terminal";
        "Mod+Shift+grave" = "window-move-to-scratchpad terminal";
        "Mod+Ctrl+grave" = "window-restore-from-scratchpad terminal";

        # --- Workspaces: Win+Ctrl+Left/Right like Windows virtual desktops.
        "Mod+Ctrl+Left" = "workspace-previous";
        "Mod+Ctrl+Right" = "workspace-next";
        "Mod+Ctrl+Shift+Left" = "window-move-to-workspace-previous";
        "Mod+Ctrl+Shift+Right" = "window-move-to-workspace-next";
        "Mod+WheelUp" = {
          action = "workspace-previous";
          cooldown_ms = 150;
        };
        "Mod+WheelDown" = {
          action = "workspace-next";
          cooldown_ms = 150;
        };

        # Layout: cycle, or jump straight to one.
        "Mod+Alt+L" = "workspace-set-layout toggle scrolling dwindle master stacking";
        "Mod+Alt+S" = "workspace-set-layout scrolling";
        "Mod+Alt+D" = "workspace-set-layout dwindle";
        "Mod+Alt+M" = "workspace-set-layout master";
        "Mod+Alt+F" = "workspace-set-layout stacking";

        "Mod+Ctrl+R" = "config-reload"; # Reload compositor config

        # --- Hardware keys, usable on the lock screen
        "XF86AudioRaiseVolume" = whenLocked (msg "volume-up");
        "XF86AudioLowerVolume" = whenLocked (msg "volume-down");
        "XF86AudioMute" = whenLocked (msg "volume-mute");
        "XF86AudioMicMute" = whenLocked (msg "mic-mute");
        "XF86AudioPlay" = whenLocked (msg "media toggle");
        "XF86AudioNext" = whenLocked (msg "media next");
        "XF86AudioPrev" = whenLocked (msg "media previous");
        "XF86MonBrightnessUp" = whenLocked (msg "brightness-up");
        "XF86MonBrightnessDown" = whenLocked (msg "brightness-down");
        # Same controls for keyboards without media keys.
        "Mod+Page_Up" = whenLocked (msg "volume-up");
        "Mod+Page_Down" = whenLocked (msg "volume-down");
        "Mod+Delete" = whenLocked (msg "mic-mute");
      }
      # Win+N switches workspace, Win+Shift+N moves the window there.
      // lib.listToAttrs (lib.concatMap (n: let
        i = toString n;
      in [
        (lib.nameValuePair "Mod+${i}" "workspace-switch ${i}")
        (lib.nameValuePair "Mod+Shift+${i}" "window-move-to-workspace ${i}")
      ]) (lib.range 1 9));
  };
}

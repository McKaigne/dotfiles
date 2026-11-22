{
  # Scrolling-layout binds after Umbriel's and niri's defaults, plus mnemonic app
  # binds. Mod is Super. Modifiers keep one meaning throughout:
  #   Mod         go: focus a window, column or workspace
  #   Mod+Shift   take the focused window along
  #   Mod+Ctrl    resize
  #   Mod+Alt     column tabs and layout mode
  # Arrows, Home/End and PgUp/PgDn come from the Kanata ext layer, and the media
  # keys from its fun layer, so nothing here duplicates them. Mod+/ lists all.
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
    # One press, one window: spawns otherwise repeat while held.
    once = action: {
      inherit action;
      repeat = false;
    };
    spawn = cmd: once "spawn ${cmd}";
    # Terminal tools open in their own foot window.
    inFoot = cmd: spawn "${foot} -e ${cmd}";
    msg = args: once "spawn ${noctalia} msg ${args}";
    whenLocked = action: {
      inherit action;
      allow_when_locked = true;
    };
    noctaliaKey = args: whenLocked "spawn ${noctalia} msg ${args}";
  in {
    programs.umbriel.settings.keybinds =
      {
        # --- Apps (mnemonic)
        "Mod+Return" = spawn foot; # terminal
        "Mod+T" = spawn foot; # Terminal
        "Mod+Z" = inFoot "zellij attach --create main"; # Zellij session
        "Mod+B" = spawn browser; # Browser (LibreWolf)
        "Mod+Shift+B" = spawn "helium"; # second Browser (Helium)
        "Mod+E" = spawn pcmanfm; # Explorer
        "Mod+C" = inFoot "emacs"; # Code (Emacs)
        "Mod+H" = inFoot "hx"; # Helix
        "Mod+G" = inFoot "lazygit"; # Git
        "Mod+M" = inFoot "btop"; # Monitor
        "Mod+P" = spawn "bitwarden"; # Passwords
        "Mod+O" = spawn "obs"; # OBS (hyde)

        # --- Shell (Noctalia)
        "Mod" = msg "panel-toggle launcher"; # tap Super
        "Alt+Tab" = msg "window-switcher";
        "Mod+A" = msg "panel-toggle control-center"; # quick settings
        "Mod+N" = msg "panel-toggle control-center notifications";
        "Mod+V" = msg "panel-toggle clipboard";
        "Mod+I" = msg "settings-toggle";
        "Mod+W" = msg "panel-toggle wallpaper";
        "Mod+L" = msg "session lock"; # Lock
        "Mod+X" = msg "panel-toggle session"; # power menu
        "Ctrl+Alt+Delete" = msg "panel-toggle session";
        "Mod+slash" = "cheatsheet-toggle";
        "Mod+F1" = "cheatsheet-toggle";

        # Screenshots: Win+Shift+S snips a region; PrtSc the screen; Alt+PrtSc the window.
        "Mod+Shift+S" = msg "screenshot-region --annotate --copy-to-clipboard --no-save-to-file";
        "Print" = msg "screenshot-fullscreen --copy-to-clipboard --no-save-to-file";
        "Alt+Print" = msg "screenshot-window --copy-to-clipboard --no-save-to-file";

        # --- Window state
        "Mod+Q" = once "window-close";
        "Alt+F4" = once "window-close";
        "Mod+F" = once "window-toggle-maximize"; # column to full width
        "Mod+Shift+F" = once "window-toggle-fullscreen";
        "Mod+Space" = once "window-toggle-floating";
        "Mod+Shift+Space" = once "window-focus-switch-floating"; # jump tiled <-> floating
        "Mod+Shift+P" = once "window-toggle-pinned";
        "Mod+Tab" = once "overview-toggle"; # task view
        "Mod+Shift+Escape" = {
          action = "shortcuts-inhibit-toggle"; # escape hatch from games/VMs
          allow_when_inhibited = true;
          repeat = false;
        };

        # --- Focus: left/right walks the strip, up/down walks the column and
        # carries on into the neighbouring workspace at its edge.
        "Mod+Left" = "window-focus-left";
        "Mod+Right" = "window-focus-right";
        "Mod+Up" = "window-focus-or-workspace-up";
        "Mod+Down" = "window-focus-or-workspace-down";
        "Mod+Home" = "column-focus-first";
        "Mod+End" = "column-focus-last";
        "Mod+Page_Up" = "workspace-previous";
        "Mod+Page_Down" = "workspace-next";
        "Mod+Escape" = once "workspace-focus-last"; # back and forth

        # --- Move the focused window the same way
        "Mod+Shift+Left" = "column-move-left";
        "Mod+Shift+Right" = "column-move-right";
        "Mod+Shift+Up" = "window-move-or-workspace-up";
        "Mod+Shift+Down" = "window-move-or-workspace-down";
        "Mod+Shift+Home" = "column-move-to-first";
        "Mod+Shift+End" = "column-move-to-last";
        "Mod+Shift+Page_Up" = "window-move-to-workspace-previous";
        "Mod+Shift+Page_Down" = "window-move-to-workspace-next";
        # Columns: stack the window into its neighbour, or split it back out.
        "Mod+bracketleft" = "window-consume-or-expel-left";
        "Mod+bracketright" = "window-consume-or-expel-right";

        # --- Resize: arrows nudge, R cycles 1/3 - 1/2 - 2/3.
        "Mod+Ctrl+Left" = "window-modify-primary-extent -0.05";
        "Mod+Ctrl+Right" = "window-modify-primary-extent +0.05";
        "Mod+Ctrl+Up" = "window-modify-secondary-extent -0.05";
        "Mod+Ctrl+Down" = "window-modify-secondary-extent +0.05";
        "Mod+minus" = "window-modify-primary-extent -0.05";
        "Mod+equal" = "window-modify-primary-extent +0.05";
        "Mod+R" = "window-cycle-primary-extent";
        "Mod+Shift+R" = "window-cycle-primary-extent-back";
        "Mod+Ctrl+C" = once "column-center";

        # --- Column tabs and layout mode
        "Mod+Alt+T" = once "column-toggle-tabbed";
        "Mod+Alt+Left" = "column-focus-tab-previous";
        "Mod+Alt+Right" = "column-focus-tab-next";
        "Mod+Alt+L" = once "workspace-set-layout toggle scrolling dwindle master stacking";
        "Mod+Alt+S" = once "workspace-set-layout scrolling";
        "Mod+Alt+D" = once "workspace-set-layout dwindle";
        "Mod+Alt+M" = once "workspace-set-layout master";
        "Mod+Alt+F" = once "workspace-set-layout stacking";

        # Quake-style terminal scratchpad.
        "Mod+grave" = "scratchpad-toggle terminal";
        "Mod+Shift+grave" = once "window-move-to-scratchpad terminal";
        "Mod+Ctrl+grave" = once "window-restore-from-scratchpad terminal";

        # --- Mouse: wheel through workspaces, Shift+wheel along the strip,
        # middle-drag to pan it.
        "Mod+WheelUp" = {
          action = "workspace-previous";
          cooldown_ms = 150;
        };
        "Mod+WheelDown" = {
          action = "workspace-next";
          cooldown_ms = 150;
        };
        "Mod+Shift+WheelUp" = "window-focus-left";
        "Mod+Shift+WheelDown" = "window-focus-right";
        "Mod+MouseMiddle" = "layout-scroll-drag";

        "Mod+Ctrl+R" = once "config-reload";

        # --- Media keys (also sent by the Kanata fun layer), usable when locked
        "XF86AudioRaiseVolume" = noctaliaKey "volume-up";
        "XF86AudioLowerVolume" = noctaliaKey "volume-down";
        "XF86AudioMute" = noctaliaKey "volume-mute";
        "XF86AudioMicMute" = noctaliaKey "mic-mute";
        "XF86AudioPlay" = noctaliaKey "media toggle";
        "XF86AudioStop" = noctaliaKey "media stop";
        "XF86AudioNext" = noctaliaKey "media next";
        "XF86AudioPrev" = noctaliaKey "media previous";
        "XF86MonBrightnessUp" = noctaliaKey "brightness-up";
        "XF86MonBrightnessDown" = noctaliaKey "brightness-down";
      }
      # Mod+N switches workspace, Mod+Shift+N takes the window there.
      // lib.listToAttrs (lib.concatMap (n: let
        i = toString n;
      in [
        (lib.nameValuePair "Mod+${i}" "workspace-switch ${i}")
        (lib.nameValuePair "Mod+Shift+${i}" "window-move-to-workspace ${i}")
      ]) (lib.range 1 9));
  };
}

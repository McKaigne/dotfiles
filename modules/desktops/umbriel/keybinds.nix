{
  # Umbriel binds, built on a few rules so every key is predictable:
  #
  #   Super belongs to the compositor; Ctrl and Alt belong to apps. The only
  #   exceptions are OS-wide conventions: Alt+Tab, Print, Ctrl+Alt+Delete.
  #
  #   One meaning per modifier:
  #     Super          go there / open it
  #     Super+Shift    take the window along, or the alternate of the same thing
  #     Super+Ctrl     rarer: columns, workspaces, system, the region grid
  #
  #   Keys keep their meaning under every modifier: Left/Right are columns,
  #   Up/Down move within a column and on into the next workspace, 1-6 are
  #   workspaces, - and = are size, [ and ] are neighbors. Letters are
  #   mnemonic: T float (Tile), Shift+T Tabs, G layout (Grid), L Lock, X power.
  #
  #   One action, one bind, and nothing Kanata already provides: arrows come
  #   from its ext layer, media keys from its fun layer, and no bind relies on
  #   tapping a bare modifier (one-shot mods). Super+/ lists everything.
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
    noctaliaAction = args: "spawn ${noctalia} msg ${args}";
    msg = args: once (noctaliaAction args);
    whenLocked = action: {
      inherit action;
      allow_when_locked = true;
    };
    noctaliaKey = args: whenLocked (noctaliaAction args);
    # Toggles must not flip back and forth while the key is held.
    noctaliaToggleKey = args: noctaliaKey args // {repeat = false;};
    # On while held, undone on release.
    peek = action: release: {
      inherit action release;
      repeat = false;
    };

    copy = "--copy-to-clipboard --no-save-to-file";
    copyAndSave = "--copy-to-clipboard --save-to-file";
  in {
    programs.umbriel.settings.keybinds =
      {
        # --- Super: open (apps and panels, mnemonic)
        "Mod+Return" = spawn foot; # terminal
        "Mod+B" = spawn browser; # Browser (LibreWolf)
        "Mod+Shift+B" = spawn "helium"; # alternate Browser (Helium)
        "Mod+D" = spawn "emacs"; # Emacs (GUI frame on the daemon)
        "Mod+E" = spawn pcmanfm; # Explorer
        "Mod+M" = inFoot "btop"; # Monitor
        "Mod+P" = spawn "bitwarden"; # Passwords

        "Mod+Space" = msg "panel-toggle launcher";
        "Mod+A" = msg "panel-toggle control-center"; # quick settings (Win+A)
        "Mod+N" = msg "panel-toggle control-center notifications";
        "Mod+V" = msg "panel-toggle clipboard"; # clipboard history (Win+V)
        "Mod+comma" = msg "settings-toggle";
        "Mod+period" = msg "panel-toggle launcher /emo"; # emoji (Win+.)
        "Mod+W" = msg "panel-toggle wallpaper";
        "Mod+X" = msg "panel-toggle session"; # power menu (Win+X)
        "Mod+slash" = peek "cheatsheet-open" "cheatsheet-close";
        "Mod+semicolon" = once "workspace-toggle-show-desktop";

        # --- Super: go
        "Mod+Left" = "window-focus-left";
        "Mod+Right" = "window-focus-right";
        "Mod+Up" = "window-focus-or-workspace-up";
        "Mod+Down" = "window-focus-or-workspace-down";
        "Mod+Page_Up" = "workspace-previous";
        "Mod+Page_Down" = "workspace-next";
        "Mod+Escape" = once "workspace-focus-last";
        "Mod+Tab" = once "overview-toggle";
        "Mod+grave" = "scratchpad-toggle terminal";

        # --- Window verbs
        "Mod+Q" = once "window-close";
        "Mod+Shift+Q" = once "window-kill";
        "Mod+F" = once "window-toggle-maximize"; # column to full width
        "Mod+Shift+F" = once "window-toggle-fullscreen";
        "Mod+R" = "window-cycle-primary-extent"; # 1/3, 1/2, 2/3
        "Mod+Shift+R" = "window-cycle-secondary-extent"; # the same for height
        "Mod+C" = once "column-center";
        "Mod+Shift+C" = once "window-center"; # floating window
        "Mod+T" = once "window-toggle-floating"; # Tile or float
        "Mod+Shift+T" = once "column-toggle-tabbed";
        "Mod+Ctrl+P" = once "window-toggle-pinned";

        # --- Size: - and = are width, Shift for height
        "Mod+minus" = "window-modify-primary-extent -0.05";
        "Mod+equal" = "window-modify-primary-extent +0.05";
        "Mod+Shift+minus" = "window-modify-secondary-extent -0.05";
        "Mod+Shift+equal" = "window-modify-secondary-extent +0.05";

        # --- Layout: G cycles it, [ and ] trade windows with the neighbors
        "Mod+G" = once "workspace-set-layout toggle scrolling dwindle master stacking";
        "Mod+Shift+G" = once "layout-toggle-split"; # dwindle
        "Mod+Ctrl+minus" = "layout-master-count-decrease";
        "Mod+Ctrl+equal" = "layout-master-count-increase";
        "Mod+bracketleft" = "window-consume-or-expel-left";
        "Mod+bracketright" = "window-consume-or-expel-right";
        "Mod+Shift+bracketleft" = "column-focus-tab-previous";
        "Mod+Shift+bracketright" = "column-focus-tab-next";

        # --- Region grid (stacking layout): the left hand is the screen.
        #   Q W E    corners and top
        #   A S D    left, bottom, right
        #   Z X C    corners; X restores the window
        "Mod+Ctrl+Q" = once "window-set-region top_left";
        "Mod+Ctrl+W" = once "window-set-region top";
        "Mod+Ctrl+E" = once "window-set-region top_right";
        "Mod+Ctrl+A" = once "window-set-region left";
        "Mod+Ctrl+S" = once "window-set-region bottom";
        "Mod+Ctrl+D" = once "window-set-region right";
        "Mod+Ctrl+Z" = once "window-set-region bottom_left";
        "Mod+Ctrl+X" = once "window-clear-region";
        "Mod+Ctrl+C" = once "window-set-region bottom_right";

        # --- Super+Shift: take the window along
        "Mod+Shift+Left" = "column-move-left";
        "Mod+Shift+Right" = "column-move-right";
        "Mod+Shift+Up" = "window-move-or-workspace-up";
        "Mod+Shift+Down" = "window-move-or-workspace-down";
        "Mod+Shift+Home" = once "column-move-to-first";
        "Mod+Shift+End" = once "column-move-to-last";
        "Mod+Shift+Page_Up" = "window-move-to-workspace-previous";
        "Mod+Shift+Page_Down" = "window-move-to-workspace-next";
        "Mod+Shift+grave" = once "window-toggle-scratchpad terminal";
        "Mod+Shift+Escape" = {
          action = "shortcuts-inhibit-toggle"; # pass shortcuts through to games/VMs
          allow_when_inhibited = true;
          repeat = false;
        };

        # --- Super+Ctrl: whole workspaces
        "Mod+Ctrl+Page_Up" = "workspace-move-up";
        "Mod+Ctrl+Page_Down" = "workspace-move-down";
        # Reserved for a second monitor:
        # "Mod+Ctrl+Left" = "output-focus-left";
        # "Mod+Ctrl+Right" = "output-focus-right";
        # "Mod+Ctrl+Up" = "output-focus-up";
        # "Mod+Ctrl+Down" = "output-focus-down";
        # "Mod+Ctrl+Shift+Left" = "column-move-to-output-left";
        # "Mod+Ctrl+Shift+Right" = "column-move-to-output-right";
        # "Mod+Ctrl+Shift+Up" = "column-move-to-output-up";
        # "Mod+Ctrl+Shift+Down" = "column-move-to-output-down";

        # --- Capture: clipboard by default, Shift+Print also saves a file
        "Mod+S" = msg "screenshot-region ${copy}";
        "Mod+Shift+S" = msg "screenshot-region --annotate ${copy}";
        "Mod+Shift+A" = msg "annotate ${copy}"; # draw on the live screen
        "Print" = msg "screenshot-fullscreen ${copy}";
        "Mod+Print" = msg "screenshot-window ${copy}";
        "Shift+Print" = msg "screenshot-fullscreen ${copyAndSave}";
        "Mod+Shift+Print" = msg "screenshot-window ${copyAndSave}";

        # --- System toggles
        "Mod+Shift+W" = msg "wifi-toggle";
        "Mod+Ctrl+B" = msg "bluetooth-toggle";
        "Mod+Ctrl+N" = msg "network-toggle";
        "Mod+Shift+P" = msg "power-cycle"; # Power profile
        "Mod+H" = msg "bar-toggle"; # Hide the bar
        "Mod+Shift+H" = msg "desktop-widgets-toggle"; # Hide the widgets
        "Mod+Shift+D" = msg "theme-mode-toggle"; # Dark or light
        "Mod+Shift+N" = msg "nightlight-force-toggle"; # Night light

        # --- Session
        "Mod+L" = msg "session lock";
        "Mod+Shift+L" = msg "session lock-and-suspend";
        "Mod+Shift+O" = once "dpms-off"; # screens Off
        "Mod+Ctrl+R" = once "config-reload";

        # --- OS-wide conventions
        "Ctrl+Alt+Delete" = msg "panel-toggle session"; # power menu
        "Alt+Tab" = msg "window-switcher";

        # --- Mouse: wheel through windows, side buttons through workspaces,
        # middle-drag to pan the strip.
        "Mod+WheelUp" = "window-focus-left";
        "Mod+WheelDown" = "window-focus-right";
        "Mod+MouseBack" = "workspace-previous";
        "Mod+MouseForward" = "workspace-next";
        "Mod+MouseMiddle" = "layout-scroll-drag";

        # --- Media keys (sent by the Kanata fun layer), usable when locked
        "XF86AudioRaiseVolume" = noctaliaKey "volume-up";
        "XF86AudioLowerVolume" = noctaliaKey "volume-down";
        "XF86AudioMute" = noctaliaToggleKey "volume-mute";
        "XF86AudioMicMute" = noctaliaToggleKey "mic-mute";
        "XF86AudioPlay" = noctaliaToggleKey "media toggle";
        "XF86AudioStop" = noctaliaToggleKey "media stop";
        "XF86AudioNext" = noctaliaKey "media next";
        "XF86AudioPrev" = noctaliaKey "media previous";
        "XF86MonBrightnessUp" = noctaliaKey "brightness-up";
        "XF86MonBrightnessDown" = noctaliaKey "brightness-down";
      }
      # Super+N goes to workspace N, Super+Shift+N takes the window there,
      # Super+Ctrl+N takes the whole column.
      // lib.listToAttrs (lib.concatMap (n: let
        i = toString n;
      in [
        (lib.nameValuePair "Mod+${i}" "workspace-switch ${i}")
        (lib.nameValuePair "Mod+Shift+${i}" "window-move-to-workspace ${i}")
        (lib.nameValuePair "Mod+Ctrl+${i}" "column-move-to-workspace ${i}")
      ]) (lib.range 1 6));
  };
}

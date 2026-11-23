{
  # Umbriel binds, built on a few rules so every key is predictable:
  #
  #   Super belongs to the compositor; Ctrl and Alt belong to apps. The only
  #   exceptions are OS-wide conventions: Alt+Tab, Alt+F4, Print, Ctrl+Alt+...
  #
  #   One meaning per modifier:
  #     Super          go there / open it
  #     Super+Shift    take the window along, or the alternate of the same thing
  #     Super+Ctrl     size and position
  #     Super+Alt      structure: floating, tabs, stacking, layout mode
  #     Ctrl+Alt       session: lock, power, reload
  #
  #   Keys keep their meaning under every modifier: Left/Right are columns,
  #   Up/Down move within a column and on into the next workspace, 1-5 are
  #   workspaces. H/J/K/L always mirror the arrows. Plain letters are apps and
  #   panels, named mnemonically; Q (close), F (maximize) and R (cycle width)
  #   are the window verbs. The everyday action gets plain Super; its rarer
  #   sibling takes a second modifier (Super+F maximizes, Super+Shift+F goes
  #   fullscreen).
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
    msg = args: once "spawn ${noctalia} msg ${args}";
    whenLocked = action: {
      inherit action;
      allow_when_locked = true;
    };
    noctaliaKey = args: whenLocked "spawn ${noctalia} msg ${args}";

    # H/J/K/L do whatever the arrows do, with the same modifiers.
    vimKeys = {
      Left = "H";
      Down = "J";
      Up = "K";
      Right = "L";
    };
    withVimKeys = binds:
      binds
      // lib.concatMapAttrs (arrow: letter:
        lib.concatMapAttrs (prefix: _:
          lib.optionalAttrs (binds ? "${prefix}${arrow}") {
            "${prefix}${letter}" = binds."${prefix}${arrow}";
          }) {
          "Mod+" = null;
          "Mod+Shift+" = null;
          "Mod+Ctrl+" = null;
          "Mod+Alt+" = null;
        })
      vimKeys;
  in {
    programs.umbriel.settings.keybinds =
      withVimKeys {
        # --- Super: open (apps and panels, mnemonic)
        "Mod+Return" = spawn foot; # terminal
        "Mod+B" = spawn browser; # Browser (LibreWolf)
        "Mod+Shift+B" = spawn "helium"; # alternate Browser (Helium)
        "Mod+D" = spawn "emacs"; # Emacs (GUI frame on the daemon)
        "Mod+E" = spawn pcmanfm; # Explorer
        "Mod+G" = spawn "emacs --eval (my-magit-repository)"; # Git (Magit, pick a repository)
        "Mod+M" = inFoot "btop"; # Monitor
        "Mod+O" = spawn "obs"; # OBS (hyde)
        "Mod+P" = spawn "bitwarden"; # Passwords

        "Mod+Space" = msg "panel-toggle launcher";
        "Mod+A" = msg "panel-toggle control-center"; # quick settings (Win+A)
        "Mod+N" = msg "panel-toggle control-center notifications";
        "Mod+Shift+N" = spawn "emacs --eval (my-org-journal)"; # today's journal Note in Emacs
        "Mod+V" = msg "panel-toggle clipboard"; # clipboard history (Win+V)
        "Mod+I" = msg "settings-toggle"; # settings (Win+I)
        "Mod+W" = msg "panel-toggle wallpaper";
        "Mod+slash" = "cheatsheet-toggle";
        "Mod+Shift+S" = msg "screenshot-region --annotate --copy-to-clipboard --no-save-to-file";

        # --- Super: go
        "Mod+Left" = "window-focus-left";
        "Mod+Right" = "window-focus-right";
        "Mod+Up" = "window-focus-or-workspace-up";
        "Mod+Down" = "window-focus-or-workspace-down";
        "Mod+Escape" = once "workspace-focus-last";
        "Mod+Tab" = once "overview-toggle";
        "Mod+grave" = "scratchpad-toggle terminal";

        # --- Window verbs
        "Mod+Q" = once "window-close";
        "Mod+F" = once "window-toggle-maximize"; # column to full width
        "Mod+Shift+F" = once "window-toggle-fullscreen";
        "Mod+R" = "window-cycle-primary-extent"; # 1/3, 1/2, 2/3

        # --- Super+Shift: take the window along
        "Mod+Shift+Left" = "column-move-left";
        "Mod+Shift+Right" = "column-move-right";
        "Mod+Shift+Up" = "window-move-or-workspace-up";
        "Mod+Shift+Down" = "window-move-or-workspace-down";
        "Mod+Shift+grave" = once "window-move-to-scratchpad terminal";
        "Mod+Shift+Escape" = {
          action = "shortcuts-inhibit-toggle"; # pass shortcuts through to games/VMs
          allow_when_inhibited = true;
          repeat = false;
        };

        # --- Super+Ctrl: size and position
        "Mod+Ctrl+Left" = "window-modify-primary-extent -0.05";
        "Mod+Ctrl+Right" = "window-modify-primary-extent +0.05";
        "Mod+Ctrl+Up" = "window-modify-secondary-extent -0.05";
        "Mod+Ctrl+Down" = "window-modify-secondary-extent +0.05";
        "Mod+Ctrl+C" = once "column-center";

        # --- Super+Alt: structure
        "Mod+Alt+Space" = once "window-toggle-floating";
        "Mod+Alt+Left" = "column-focus-tab-previous";
        "Mod+Alt+Right" = "column-focus-tab-next";
        "Mod+Alt+T" = once "column-toggle-tabbed";
        "Mod+Alt+bracketleft" = "window-consume-or-expel-left";
        "Mod+Alt+bracketright" = "window-consume-or-expel-right";
        "Mod+Alt+P" = once "window-toggle-pinned";
        "Mod+Alt+grave" = once "window-restore-from-scratchpad terminal";
        "Mod+Alt+Tab" = once "workspace-set-layout toggle scrolling dwindle master stacking"; # cycle layouts

        # --- Ctrl+Alt: session
        "Ctrl+Alt+L" = msg "session lock";
        "Ctrl+Alt+Delete" = msg "panel-toggle session"; # power menu
        "Ctrl+Alt+R" = once "config-reload"; # reload the compositor config

        # --- OS-wide conventions
        "Alt+Tab" = msg "window-switcher";
        "Print" = msg "screenshot-fullscreen --copy-to-clipboard --no-save-to-file";
        "Alt+Print" = msg "screenshot-window --copy-to-clipboard --no-save-to-file";

        # --- Mouse: wheel through workspaces, Shift+wheel along the columns,
        # middle-drag to pan the strip.
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

        # --- Media keys (sent by the Kanata fun layer), usable when locked
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
      # Super+N goes to workspace N, Super+Shift+N takes the window there.
      // lib.listToAttrs (lib.concatMap (n: let
        i = toString n;
      in [
        (lib.nameValuePair "Mod+${i}" "workspace-switch ${i}")
        (lib.nameValuePair "Mod+Shift+${i}" "window-move-to-workspace ${i}")
      ]) (lib.range 1 5));
  };
}

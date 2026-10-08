{ config, pkgs, inputs, lib, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  user = config.mainUser;
  noctaliaPkg = inputs.noctalia.packages.${system}.default;

  noctaliaThemeSync = pkgs.writeShellScriptBin "noctalia-theme-sync" ''
    set -euo pipefail

    MODE="prefer-dark"
    GTK_THEME="adw-gtk3-dark"

    SETTINGS="$HOME/.config/noctalia/settings.json"
    if [ -f "$SETTINGS" ]; then
      IS_DARK=$(${pkgs.jq}/bin/jq -r 'if .colorSchemes.darkMode != null then .colorSchemes.darkMode elif .theme.mode != null then (.theme.mode == "dark") else true end' "$SETTINGS" 2>/dev/null || echo "true")
      if [ "$IS_DARK" = "false" ]; then
        MODE="prefer-light"
        GTK_THEME="adw-gtk3"
      fi
    fi

    # Ensure GLib finds schemas for org.gnome.desktop.interface
    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

    # Broadcast to GSettings and dconf so xdg-desktop-portal updates Chromium, Brave, and GTK apps live
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "$MODE" 2>/dev/null || true
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'$MODE'" 2>/dev/null || true
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'$GTK_THEME'" 2>/dev/null || true

    # Synchronize Brave Preferences live if the file exists
    PREF_FILE="$HOME/.config/BraveSoftware/Brave-Origin/Default/Preferences"
    if [ -f "$PREF_FILE" ]; then
      ${pkgs.jq}/bin/jq '
        .extensions = (.extensions // {}) |
        .extensions.theme = (.extensions.theme // {}) |
        .extensions.theme.use_system = true |
        .extensions.theme.system_theme = 1
      ' "$PREF_FILE" > "$PREF_FILE.tmp" && mv "$PREF_FILE.tmp" "$PREF_FILE" 2>/dev/null || true
    fi

    if command -v niri &>/dev/null && [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      niri msg action load-config-file 2>/dev/null || true
    fi
    pkill -USR2 cava 2>/dev/null || true
    systemctl --user restart easyeffects 2>/dev/null || true
  '';

  settingsJsonText = builtins.toJSON {
    settingsVersion = 59;
    appLauncher = {
      autoPasteClipboard = false;
      clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
      clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
      clipboardWrapText = true;
      customLaunchPrefix = "systemd-run --user --scope --collect --";
      customLaunchPrefixEnabled = true;
      density = "default";
      enableClipPreview = true;
      enableClipboardChips = true;
      enableClipboardHistory = false;
      enableClipboardSmartIcons = true;
      enableSessionSearch = true;
      enableSettingsSearch = true;
      enableWindowsSearch = true;
      iconMode = "tabler";
      ignoreMouseInput = false;
      overviewLayer = false;
      pinnedApps = [];
      position = "center";
      screenshotAnnotationTool = "";
      showCategories = true;
      showIconBackground = false;
      sortByMostUsed = true;
      terminalCommand = "ghostty -e";
      viewMode = "list";
    };
    audio = {
      mprisBlacklist = [];
      preferredPlayer = "";
      spectrumFrameRate = 30;
      spectrumMirrored = true;
      visualizerType = "linear";
      volumeFeedback = false;
      volumeFeedbackSoundFile = "";
      volumeOverdrive = false;
      volumeStep = 5;
    };
    bar = {
      autoHideDelay = 500;
      autoShowDelay = 150;
      backgroundOpacity = 0.85;
      barType = "floating";
      capsuleColorKey = "none";
      capsuleOpacity = 0.85;
      contentPadding = 2;
      density = "default";
      displayMode = "always_visible";
      enableExclusionZoneInset = true;
      fontScale = 1;
      frameRadius = 12;
      frameThickness = 8;
      hideOnOverview = false;
      marginHorizontal = 4;
      marginVertical = 4;
      middleClickAction = "none";
      middleClickCommand = "";
      middleClickFollowMouse = false;
      monitors = [];
      mouseWheelAction = "none";
      mouseWheelWrap = true;
      outerCorners = false;
      position = "bottom";
      reverseScroll = false;
      rightClickAction = "controlCenter";
      rightClickCommand = "";
      rightClickFollowMouse = true;
      screenOverrides = [];
      showCapsule = true;
      showOnWorkspaceSwitch = true;
      showOutline = false;
      useSeparateOpacity = false;
      widgetSpacing = 6;
      widgets = {
        center = [
          {
            characterCount = 2;
            colorizeIcons = false;
            emptyColor = "secondary";
            enableScrollWheel = true;
            focusedColor = "primary";
            followFocusedScreen = false;
            fontWeight = "bold";
            groupedBorderOpacity = 1;
            hideUnoccupied = false;
            iconScale = 0.8;
            id = "Workspace";
            labelMode = "none";
            occupiedColor = "secondary";
            pillSize = 0.45;
            showApplications = false;
            showApplicationsHover = false;
            showBadge = true;
            showLabelsOnlyWhenOccupied = true;
            unfocusedIconsOpacity = 1;
          }
        ];
        left = [
          {
            colorizeSystemIcon = "none";
            colorizeSystemText = "none";
            customIconPath = "";
            enableColorization = false;
            icon = "rocket";
            iconColor = "none";
            id = "Launcher";
            useDistroLogo = false;
          }
          {
            clockColor = "none";
            customFont = "";
            formatHorizontal = "HH:mm  ddd, MMM dd";
            formatVertical = "HH mm - dd MM";
            id = "Clock";
            tooltipFormat = "HH:mm ddd, MMM dd";
            useCustomFont = false;
          }
          {
            compactMode = true;
            diskPath = "/";
            iconColor = "none";
            id = "SystemMonitor";
            showCpuCores = false;
            showCpuFreq = false;
            showCpuTemp = true;
            showCpuUsage = true;
            showDiskAvailable = false;
            showDiskUsage = false;
            showDiskUsageAsPercent = false;
            showGpuTemp = false;
            showLoadAverage = false;
            showMemoryAsPercent = false;
            showMemoryUsage = true;
            showNetworkStats = false;
            showSwapUsage = false;
            textColor = "none";
            useMonospaceFont = true;
            usePadding = false;
          }
          {
            compactMode = false;
            hideMode = "hidden";
            hideWhenIdle = false;
            id = "MediaMini";
            maxWidth = 145;
            panelShowAlbumArt = true;
            scrollingMode = "hover";
            showAlbumArt = true;
            showArtistFirst = true;
            showProgressRing = true;
            showVisualizer = false;
            textColor = "none";
            useFixedWidth = false;
            visualizerType = "linear";
          }
        ];
        right = [
          {
            blacklist = [];
            chevronColor = "none";
            colorizeIcons = false;
            drawerEnabled = true;
            hidePassive = false;
            id = "Tray";
            pinned = [];
          }
          {
            hideWhenZero = false;
            hideWhenZeroUnread = false;
            iconColor = "none";
            id = "NotificationHistory";
            showUnreadBadge = true;
            unreadBadgeColor = "primary";
          }
          {
            displayMode = "onhover";
            iconColor = "none";
            id = "Network";
            textColor = "none";
          }
          {
            deviceNativePath = "__default__";
            displayMode = "graphic";
            hideIfIdle = false;
            hideIfNotDetected = true;
            id = "Battery";
            showNoctaliaPerformance = false;
            showPowerProfiles = false;
          }
          {
            colorizeDistroLogo = false;
            colorizeSystemIcon = "none";
            colorizeSystemText = "none";
            customIconPath = "";
            enableColorization = false;
            icon = "assembly-filled";
            id = "ControlCenter";
            useDistroLogo = false;
          }
        ];
      };
    };
    brightness = {
      backlightDeviceMappings = [];
      brightnessStep = 5;
      enableDdcSupport = false;
      enforceMinimum = true;
    };
    calendar = {
      cards = [
        { enabled = true; id = "calendar-header-card"; }
        { enabled = true; id = "calendar-month-card"; }
        { enabled = true; id = "weather-card"; }
      ];
    };
    colorSchemes = {
      darkMode = true;
      generationMethod = "tonal-spot";
      manualSunrise = "06:30";
      manualSunset = "18:30";
      monitorForColors = "";
      predefinedScheme = "Catppuccin";
      schedulingMode = "off";
      syncGsettings = true;
      useWallpaperColors = false;
    };
    controlCenter = {
      cards = [
        { enabled = true; id = "profile-card"; }
        { enabled = true; id = "shortcuts-card"; }
        { enabled = true; id = "audio-card"; }
        { enabled = false; id = "brightness-card"; }
        { enabled = true; id = "weather-card"; }
        { enabled = true; id = "media-sysmon-card"; }
      ];
      diskPath = "/";
      position = "close_to_bar_button";
      shortcuts = {
        left = [
          { id = "Network"; }
          { id = "Bluetooth"; }
          { id = "WallpaperSelector"; }
          { id = "NoctaliaPerformance"; }
        ];
        right = [
          { id = "Notifications"; }
          { id = "PowerProfile"; }
          { id = "KeepAwake"; }
          { id = "NightLight"; }
        ];
      };
    };
    desktopWidgets = {
      enabled = false;
      gridSnap = false;
      gridSnapScale = false;
      monitorWidgets = [];
      overviewEnabled = true;
    };
    dock = {
      animationSpeed = 1;
      backgroundOpacity = 1;
      colorizeIcons = false;
      deadOpacity = 0.6;
      displayMode = "auto_hide";
      dockType = "floating";
      enabled = false;
      floatingRatio = 1;
      groupApps = false;
      groupClickAction = "cycle";
      groupContextMenuMode = "extended";
      groupIndicatorStyle = "dots";
      inactiveIndicators = false;
      indicatorColor = "primary";
      indicatorOpacity = 0.6;
      indicatorThickness = 3;
      launcherIcon = "";
      launcherIconColor = "none";
      launcherPosition = "end";
      launcherUseDistroLogo = false;
      monitors = [];
      onlySameOutput = true;
      pinnedApps = [];
      pinnedStatic = false;
      position = "bottom";
      showDockIndicator = false;
      showLauncherIcon = false;
      sitOnFrame = false;
      size = 1;
    };
    general = {
      allowPanelsOnScreenWithoutBar = true;
      allowPasswordWithFprintd = false;
      animationDisabled = false;
      animationSpeed = 1;
      autoStartAuth = false;
      avatarImage = "/home/${user}/.face";
      boxRadiusRatio = 1;
      clockFormat = "hh\\HH:mmmm ";
      clockStyle = "custom";
      compactLockScreen = false;
      dimmerOpacity = 0.0;
      enableBlurBehind = true;
      enableLockScreenCountdown = true;
      enableLockScreenMediaControls = false;
      enableShadows = true;
      forceBlackScreenCorners = true;
      iRadiusRatio = 1;
      keybinds = {
        keyDown = [ "Down" ];
        keyEnter = [ "Return" "Enter" ];
        keyEscape = [ "Esc" ];
        keyLeft = [ "Left" ];
        keyRemove = [ "Del" ];
        keyRight = [ "Right" ];
        keyUp = [ "Up" ];
      };
      language = "";
      lockOnSuspend = true;
      lockScreenAnimations = false;
      lockScreenBlur = 0;
      lockScreenCountdownDuration = 10000;
      lockScreenMonitors = [];
      lockScreenTint = 0;
      passwordChars = false;
      radiusRatio = 1;
      reverseScroll = false;
      scaleRatio = 0.9;
      screenRadiusRatio = 1;
      shadowDirection = "bottom_left";
      shadowOffsetX = -2;
      shadowOffsetY = 2;
      showChangelogOnStartup = true;
      showHibernateOnLockScreen = false;
      showScreenCorners = true;
      showSessionButtonsOnLockScreen = true;
      smoothScrollEnabled = true;
      telemetryEnabled = false;
    };
    hooks = {
      colorGeneration = "${noctaliaThemeSync}/bin/noctalia-theme-sync";
      darkModeChange = "";
      enabled = true;
      performanceModeDisabled = "";
      performanceModeEnabled = "";
      screenLock = "";
      screenUnlock = "";
      session = "";
      startup = "${noctaliaThemeSync}/bin/noctalia-theme-sync";
      wallpaperChange = "";
    };
    idle = {
      customCommands = "[]";
      enabled = false;
      fadeDuration = 5;
      lockCommand = "";
      lockTimeout = 660;
      resumeLockCommand = "";
      resumeScreenOffCommand = "";
      resumeSuspendCommand = "";
      screenOffCommand = "";
      screenOffTimeout = 600;
      suspendCommand = "";
      suspendTimeout = 1800;
    };
    location = {
      analogClockInCalendar = false;
      autoLocate = false;
      firstDayOfWeek = -1;
      hideWeatherCityName = false;
      hideWeatherTimezone = false;
      name = "Iloilo City";
      showCalendarEvents = true;
      showCalendarWeather = true;
      showWeekNumberInCalendar = false;
      use12hourFormat = false;
      useFahrenheit = false;
      weatherEnabled = true;
      weatherShowEffects = true;
      weatherTaliaMascotAlways = false;
    };
    network = {
      bluetoothAutoConnect = true;
      bluetoothDetailsViewMode = "grid";
      bluetoothHideUnnamedDevices = false;
      bluetoothRssiPollIntervalMs = 60000;
      bluetoothRssiPollingEnabled = false;
      disableDiscoverability = false;
      networkPanelView = "wifi";
      wifiDetailsViewMode = "grid";
    };
    nightLight = {
      autoSchedule = true;
      dayTemp = "6500";
      enabled = true;
      forced = false;
      manualSunrise = "06:30";
      manualSunset = "18:30";
      nightTemp = "4000";
    };
    noctaliaPerformance = {
      disableDesktopWidgets = true;
      disableWallpaper = true;
    };
    notifications = {
      backgroundOpacity = 1;
      clearDismissed = true;
      criticalUrgencyDuration = 15;
      density = "default";
      enableBatteryToast = true;
      enableKeyboardLayoutToast = true;
      enableMarkdown = false;
      enableMediaToast = false;
      enabled = true;
      location = "top_right";
      lowUrgencyDuration = 3;
      monitors = [];
      normalUrgencyDuration = 8;
      overlayLayer = true;
      respectExpireTimeout = false;
      saveToHistory = {
        critical = true;
        low = true;
        normal = true;
      };
      sounds = {
        criticalSoundFile = "";
        enabled = false;
        excludedApps = "discord,firefox,chrome,chromium,edge";
        lowSoundFile = "";
        normalSoundFile = "";
        separateSounds = false;
        volume = 0.5;
      };
    };
    osd = {
      autoHideMs = 2000;
      backgroundOpacity = 1;
      enabled = true;
      enabledTypes = [ 0 1 2 ];
      location = "top_right";
      monitors = [];
      overlayLayer = true;
    };
    plugins = {
      autoUpdate = false;
      notifyUpdates = true;
    };
    sessionMenu = {
      countdownDuration = 10000;
      enableCountdown = true;
      largeButtonsLayout = "single-row";
      largeButtonsStyle = true;
      position = "center";
      powerOptions = [
        { action = "lock"; command = ""; countdownEnabled = true; enabled = true; keybind = "1"; }
        { action = "suspend"; command = ""; countdownEnabled = true; enabled = true; keybind = "2"; }
        { action = "hibernate"; command = ""; countdownEnabled = true; enabled = true; keybind = "3"; }
        { action = "reboot"; command = ""; countdownEnabled = true; enabled = true; keybind = "4"; }
        { action = "logout"; command = ""; countdownEnabled = true; enabled = true; keybind = "5"; }
        { action = "shutdown"; command = ""; countdownEnabled = true; enabled = true; keybind = "6"; }
        { action = "rebootToUefi"; command = ""; countdownEnabled = true; enabled = true; keybind = "7"; }
        { action = "userspaceReboot"; command = ""; countdownEnabled = true; enabled = false; keybind = ""; }
      ];
      showHeader = true;
      showKeybinds = true;
    };
    systemMonitor = {
      batteryCriticalThreshold = 5;
      batteryWarningThreshold = 20;
      cpuCriticalThreshold = 90;
      cpuWarningThreshold = 80;
      criticalColor = "";
      diskAvailCriticalThreshold = 10;
      diskAvailWarningThreshold = 20;
      diskCriticalThreshold = 90;
      diskWarningThreshold = 80;
      enableDgpuMonitoring = false;
      externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
      gpuCriticalThreshold = 90;
      gpuWarningThreshold = 80;
      memCriticalThreshold = 90;
      memWarningThreshold = 80;
      swapCriticalThreshold = 90;
      swapWarningThreshold = 80;
      tempCriticalThreshold = 90;
      tempWarningThreshold = 80;
      useCustomColors = false;
      warningColor = "";
    };
    templates = {
      activeTemplates = [
        { enabled = true; id = "cava"; }
        { enabled = true; id = "starship"; }
        { enabled = true; id = "niri"; }
        { enabled = true; id = "qt"; }
        { enabled = true; id = "gtk"; }
        { enabled = true; id = "helix"; }
        { enabled = true; id = "zathura"; }
        { enabled = true; id = "ghostty"; }
        { enabled = true; id = "btop"; }
      ];
      enableUserTheming = true;
    };
    ui = {
      boxBorderEnabled = false;
      fontDefault = "Sans Serif";
      fontDefaultScale = 1;
      fontFixed = "monospace";
      fontFixedScale = 1;
      panelBackgroundOpacity = 0.85;
      panelsAttachedToBar = true;
      scrollbarAlwaysVisible = false;
      settingsPanelMode = "attached";
      settingsPanelSideBarCardStyle = false;
      tooltipsEnabled = true;
      translucentWidgets = true;
    };
    wallpaper = {
      automationEnabled = false;
      directory = "/etc/nixos/wallpapers";
      enableMultiMonitorDirectories = false;
      enabled = true;
      favorites = [];
      fillColor = "#f9f9f9";
      fillMode = "crop";
      hideWallpaperFilenames = false;
      linkLightAndDarkWallpapers = true;
      monitorDirectories = [];
      overviewBlur = 0.4;
      overviewEnabled = false;
      overviewTint = 0.6;
      panelPosition = "follow_bar";
      randomIntervalSec = 300;
      setWallpaperOnAllMonitors = true;
      showHiddenFiles = false;
      skipStartupTransition = false;
      solidColor = "#1a1a2e";
      sortOrder = "name";
      transitionDuration = 1500;
      transitionEdgeSmoothness = 0.05;
      transitionType = [ "honeycomb" "pixelate" ];
      useOriginalImages = true;
      useSolidColor = false;
      useWallhaven = false;
      viewMode = "single";
      wallhavenApiKey = "";
      wallhavenCategories = "111";
      wallhavenOrder = "desc";
      wallhavenPurity = "100";
      wallhavenQuery = "";
      wallhavenRatios = "";
      wallhavenResolutionHeight = "";
      wallhavenResolutionMode = "atleast";
      wallhavenResolutionWidth = "";
      wallhavenSorting = "relevance";
      wallpaperChangeMode = "random";
    };
  };
in
{
  environment.systemPackages = [
    noctaliaThemeSync
    pkgs.glib
    pkgs.dconf
    pkgs.gsettings-desktop-schemas
  ];

  home-manager.users.${user} = { lib, ... }: {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      settings = {
        theme = {
          mode = "dark";
          palette = "catppuccin-mocha";
          templates = {
            enable_builtin_templates = true;
            enable_user_templates = true;
            builtin_ids = [
              "btop"
              "cava"
              "fuzzel"
              "ghostty"
              "gtk3"
              "gtk4"
              "helix"
              "niri"
              "qt"
              "starship"
              "zathura"
            ];
            user = {
              cliamp = {
                input_path = "/home/${user}/.config/noctalia/templates/cliamp.toml";
                output_path = "/home/${user}/.config/cliamp/themes/noctalia.toml";
              };
              zellij = {
                input_path = "/home/${user}/.config/noctalia/templates/zellij.kdl";
                output_path = "/home/${user}/.config/zellij/themes/noctalia.kdl";
              };
              kde = {
                input_path = "/home/${user}/.config/noctalia/templates/kde-noctalia.colors";
                output_path = "/home/${user}/.local/share/color-schemes/noctalia.colors";
              };
            };
          };
        };
        hooks = {
          enabled = true;
          colorGeneration = "${noctaliaThemeSync}/bin/noctalia-theme-sync";
          startup = "${noctaliaThemeSync}/bin/noctalia-theme-sync";
          darkModeChange = "${noctaliaThemeSync}/bin/noctalia-theme-sync";
        };
        wallpaper = {
          enabled = true;
          directory = "/etc/nixos/wallpapers";
          change_mode = "random";
          interval_sec = 300;
          transition = "honeycomb";
        };
        nightlight = {
          enabled = true;
          day_temp = 6500;
          night_temp = 4000;
          auto_schedule = true;
        };
        bar = {
          "default" = {
            position = "bottom";
            floating = true;
            margin_ends = 6;
            margin_edge = 6;
            frame_radius = 12;
            opacity = 0.85;
            widgets_left = [ "launcher" "clock" "system-monitor" "media-mini" ];
            widgets_center = [ "workspace" ];
            widgets_right = [ "tray" "notifications" "network" "battery" "control-center" ];
          };
        };
        launcher = {
          position = "center";
          view_mode = "list";
          sort_by_used = true;
          terminal_command = "ghostty -e";
          enable_clipboard = true;
          enable_session_search = true;
        };
        control_center = {
          position = "close_to_button";
        };
        notifications = {
          location = "top_right";
          normal_timeout = 8;
          critical_timeout = 15;
          enable_markdown = true;
        };
        lockscreen = {
          countdown_sec = 10;
          allow_hibernate = false;
        };
      };
    };

    # Declarative Btop configuration: Upstream default layout + Noctalia theme
    xdg.configFile."btop/btop.conf" = {
      text = ''
        color_theme = "noctalia"
        theme_background = False
        truecolor = True
        rounded_corners = True
      '';
      force = true;
    };

    # Noctalia Plugins declaration
    xdg.configFile."noctalia/plugins.json" = {
      text = builtins.toJSON {
        sources = [
          {
            enabled = true;
            name = "Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {};
        version = 2;
      };
      force = true;
    };

    # Noctalia Templates
    xdg.configFile."noctalia/templates/cliamp.toml" = {
      text = ''
        accent = "{{ colors.primary.default.hex }}"
        bright_fg = "{{ colors.on_surface.default.hex }}"
        fg = "{{ colors.on_surface_variant.default.hex }}"
        green = "{{ colors.primary.default.hex }}"
        yellow = "{{ colors.secondary.default.hex }}"
        red = "{{ colors.tertiary.default.hex }}"
      '';
      force = true;
    };

    xdg.configFile."noctalia/templates/zellij.kdl" = {
      text = ''
        themes {
          noctalia {
            fg "{{ colors.on_surface.default.hex }}"
            bg "{{ colors.surface.default.hex }}"
            black "{{ colors.surface_container_high.default.hex }}"
            red "{{ colors.error.default.hex }}"
            green "{{ colors.tertiary.default.hex }}"
            yellow "{{ colors.secondary.default.hex }}"
            blue "{{ colors.primary.default.hex }}"
            magenta "{{ colors.tertiary.default.hex }}"
            cyan "{{ colors.secondary.default.hex }}"
            white "{{ colors.on_surface_variant.default.hex }}"
            orange "{{ colors.primary_container.default.hex }}"
          }
        }
      '';
      force = true;
    };

    xdg.configFile."noctalia/templates/kde-noctalia.colors" = {
      text = ''
        [General]
        ColorScheme=noctalia
        Name=noctalia
        shadeSortColumn=true

        [Colors:Window]
        BackgroundNormal={{ colors.surface.default.red }},{{ colors.surface.default.green }},{{ colors.surface.default.blue }}
        BackgroundAlternate={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:View]
        BackgroundNormal={{ colors.surface.default.red }},{{ colors.surface.default.green }},{{ colors.surface.default.blue }}
        BackgroundAlternate={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Button]
        BackgroundNormal={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        BackgroundAlternate={{ colors.surface_container_high.default.red }},{{ colors.surface_container_high.default.green }},{{ colors.surface_container_high.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Selection]
        BackgroundNormal={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        BackgroundAlternate={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundNormal={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundInactive={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundActive={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundLink={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundVisited={{ colors.on_primary.default.red }},{{ colors.on_primary.default.green }},{{ colors.on_primary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Tooltip]
        BackgroundNormal={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        BackgroundAlternate={{ colors.surface_container_high.default.red }},{{ colors.surface_container_high.default.green }},{{ colors.surface_container_high.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Complementary]
        BackgroundNormal={{ colors.surface.default.red }},{{ colors.surface.default.green }},{{ colors.surface.default.blue }}
        BackgroundAlternate={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [Colors:Header]
        BackgroundNormal={{ colors.surface.default.red }},{{ colors.surface.default.green }},{{ colors.surface.default.blue }}
        BackgroundAlternate={{ colors.surface_container.default.red }},{{ colors.surface_container.default.green }},{{ colors.surface_container.default.blue }}
        ForegroundNormal={{ colors.on_surface.default.red }},{{ colors.on_surface.default.green }},{{ colors.on_surface.default.blue }}
        ForegroundInactive={{ colors.on_surface_variant.default.red }},{{ colors.on_surface_variant.default.green }},{{ colors.on_surface_variant.default.blue }}
        ForegroundActive={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundLink={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundVisited={{ colors.secondary.default.red }},{{ colors.secondary.default.green }},{{ colors.secondary.default.blue }}
        ForegroundNegative={{ colors.error.default.red }},{{ colors.error.default.green }},{{ colors.error.default.blue }}
        ForegroundNeutral={{ colors.primary.default.red }},{{ colors.primary.default.green }},{{ colors.primary.default.blue }}
        ForegroundPositive={{ colors.tertiary.default.red }},{{ colors.tertiary.default.green }},{{ colors.tertiary.default.blue }}

        [KDE]
        colorScheme=noctalia
      '';
      force = true;
    };

    # Dynamic mutable seeding of GUI settings.json (allows Noctalia GUI writes while keeping machines synced)
    home.activation.seedNoctalia = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.config/helix/themes \
               $HOME/.config/ghostty/themes \
               $HOME/.config/niri \
               $HOME/.config/fuzzel/themes \
               $HOME/.config/gtk-3.0 \
               $HOME/.config/gtk-4.0 \
               $HOME/.config/noctalia/hooks \
               $HOME/.config/noctalia/templates \
               $HOME/.config/zellij/themes \
               $HOME/.config/cliamp/themes \
               $HOME/.config/btop/themes \
               $HOME/.config/qt5ct/colors \
               $HOME/.config/qt6ct/colors \
               $HOME/.local/share/color-schemes

      cat <<'NOCTALIA_JSON' > $HOME/.config/noctalia/settings.json
${settingsJsonText}
NOCTALIA_JSON

      ln -sf ${noctaliaThemeSync}/bin/noctalia-theme-sync $HOME/.config/noctalia/hooks/theme-sync.sh
    '';
  };
}

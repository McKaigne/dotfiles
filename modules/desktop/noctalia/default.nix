{ config, pkgs, inputs, lib, ... }:
let
  user = config.mainUser;
  userHome = config.users.users.${user}.home;

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

    export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "$MODE" 2>/dev/null || true
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'$MODE'" 2>/dev/null || true
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'$GTK_THEME'" 2>/dev/null || true

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
in
{
  environment.systemPackages = [
    noctaliaThemeSync
    pkgs.glib
    pkgs.dconf
    pkgs.gsettings-desktop-schemas
  ];

  home-manager.users.${user} = { config, lib, ... }: {
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
                input_path = "${userHome}/.config/noctalia/templates/cliamp.toml";
                output_path = "${userHome}/.config/cliamp/themes/noctalia.toml";
              };
              zellij = {
                input_path = "${userHome}/.config/noctalia/templates/zellij.kdl";
                output_path = "${userHome}/.config/zellij/themes/noctalia.kdl";
              };
              kde = {
                input_path = "${userHome}/.config/noctalia/templates/kde-noctalia.colors";
                output_path = "${userHome}/.local/share/color-schemes/noctalia.colors";
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

    # Bi-directional out-of-store symlinks to /etc/nixos
    xdg.configFile."noctalia/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/desktop/noctalia/settings.json";

    xdg.configFile."noctalia/plugins.json".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/desktop/noctalia/plugins.json";

    xdg.configFile."noctalia/templates/cliamp.toml".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/desktop/noctalia/templates/cliamp.toml";

    xdg.configFile."noctalia/templates/zellij.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/desktop/noctalia/templates/zellij.kdl";

    xdg.configFile."noctalia/templates/kde-noctalia.colors".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/desktop/noctalia/templates/kde-noctalia.colors";

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
  };
}

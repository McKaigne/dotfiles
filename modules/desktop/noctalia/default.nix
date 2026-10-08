{ config, pkgs, inputs, lib, ... }:
let
  user = config.mainUser;

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

  # Guarantee wallpaper directory exists on any fresh machine
  systemd.tmpfiles.rules = [
    "d /etc/nixos/wallpapers 0755 root root -"
  ];

  home-manager.users.${user} = { lib, ... }: {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia.enable = true;

    # Model B: Hands-off mutable seeding on activation
    home.activation.seedNoctaliaSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      SETTINGS_DIR="$HOME/.config/noctalia"
      SETTINGS_FILE="$SETTINGS_DIR/settings.json"
      mkdir -p "$SETTINGS_DIR"
      
      # If the file does not exist or is currently a read-only symlink, seed it as a regular file
      if [ ! -f "$SETTINGS_FILE" ] || [ -L "$SETTINGS_FILE" ]; then
        rm -f "$SETTINGS_FILE"
        cp ${./settings.json} "$SETTINGS_FILE"
        chmod 644 "$SETTINGS_FILE"
      fi
    '';

    # Declarative templates and plugins
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

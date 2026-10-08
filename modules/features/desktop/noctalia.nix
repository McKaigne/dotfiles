{ self, inputs, ... }: {
  flake.nixosModules.noctalia = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
    noctaliaJson = ./noctalia.json;

    syncScript = pkgs.writeShellScript "noctalia-sync-to-git" ''
      set -euo pipefail
      SRC="$HOME/.config/noctalia/settings.json"
      DEST="/etc/nixos/modules/features/desktop/noctalia.json"

      if [ -f "$SRC" ] && [ -w "/etc/nixos" ]; then
        ${pkgs.jq}/bin/jq '
          .general.avatarImage = "" |
          .wallpaper.directory = "/etc/nixos/wallpapers"
        ' "$SRC" > "$DEST"
        ${pkgs.git}/bin/git -C /etc/nixos add "$DEST" 2>/dev/null || true
      fi
    '';
  in
  {
    environment.systemPackages = [
      pkgs.glib
      pkgs.dconf
      pkgs.gsettings-desktop-schemas
    ];

    systemd.user.paths.noctalia-sync = {
      description = "Watch Noctalia settings.json for GUI updates";
      wantedBy = [ "graphical-session.target" ];
      pathConfig = {
        PathModified = "%h/.config/noctalia/settings.json";
        Unit = "noctalia-sync.service";
      };
    };

    systemd.user.services.noctalia-sync = {
      description = "Sync updated Noctalia GUI settings into Git tree";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${syncScript}";
      };
    };

    home-manager.users.${user} = { lib, ... }: {
      imports = [ inputs.noctalia.homeModules.default ];
      programs.noctalia.enable = true;

      home.activation.seedNoctaliaSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
        SETTINGS_DIR="$HOME/.config/noctalia"
        SETTINGS_FILE="$SETTINGS_DIR/settings.json"
        mkdir -p "$SETTINGS_DIR"
        if [ ! -f "$SETTINGS_FILE" ] || [ -L "$SETTINGS_FILE" ]; then
          rm -f "$SETTINGS_FILE"
          cp ${noctaliaJson} "$SETTINGS_FILE"
          chmod 644 "$SETTINGS_FILE"
        fi
      '';

      xdg.configFile."noctalia/templates/cliamp.toml".text = ''
        accent = "{{ colors.primary.default.hex }}"
        bright_fg = "{{ colors.on_surface.default.hex }}"
        fg = "{{ colors.on_surface_variant.default.hex }}"
        green = "{{ colors.primary.default.hex }}"
        yellow = "{{ colors.secondary.default.hex }}"
        red = "{{ colors.error.default.hex }}"
      '';

      xdg.configFile."noctalia/templates/zellij.kdl".text = ''
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
            cyan "{{ colors.primary.default.hex }}"
            white "{{ colors.on_surface_variant.default.hex }}"
            orange "{{ colors.primary_container.default.hex }}"
          }
        }
      '';

      xdg.configFile."noctalia/templates/ghostty".text = ''
        background = {{ colors.surface.default.hex }}
        foreground = {{ colors.on_surface.default.hex }}
        selection-background = {{ colors.surface_container.default.hex }}
        selection-foreground = {{ colors.on_surface.default.hex }}
        cursor-color = {{ colors.primary.default.hex }}
      '';

      xdg.configFile."noctalia/templates/helix.toml".text = ''
        inherits = "solarized_dark"
        "ui.background" = { bg = "none" }
        "ui.cursor.primary" = { fg = "{{ colors.surface.default.hex }}", bg = "{{ colors.primary.default.hex }}" }
      '';

      xdg.configFile."noctalia/templates/zathurarc".text = ''
        set default-bg "{{ colors.surface.default.hex }}"
        set default-fg "{{ colors.on_surface.default.hex }}"
        set statusbar-bg "{{ colors.surface_container.default.hex }}"
        set statusbar-fg "{{ colors.on_surface.default.hex }}"
        set highlight-color "{{ colors.primary.default.hex }}"
      '';

      xdg.configFile."noctalia/templates/btop.theme".text = ''
        theme[main_bg]="{{ colors.surface.default.hex }}"
        theme[main_fg]="{{ colors.on_surface.default.hex }}"
        theme[title]="{{ colors.primary.default.hex }}"
        theme[selected_bg]="{{ colors.surface_container.default.hex }}"
        theme[selected_fg]="{{ colors.on_surface.default.hex }}"
      '';

      xdg.configFile."noctalia/plugins.json".text = builtins.toJSON {
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
    };
  };
}

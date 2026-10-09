{ self, inputs, ... }: {
  flake.nixosModules.noctalia = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
    noctaliaConfigToml = ./config.toml;
  in
  {
    environment.systemPackages = [
      pkgs.glib
      pkgs.dconf
      pkgs.gsettings-desktop-schemas
    ];

    home-manager.users.${user} = { lib, ... }: {
      imports = [ inputs.noctalia.homeModules.default ];
      programs.noctalia.enable = true;

      home.activation.seedNoctaliaConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        CONFIG_DIR="$HOME/.config/noctalia"
        CONFIG_FILE="$CONFIG_DIR/config.toml"
        mkdir -p "$CONFIG_DIR"
        rm -f "$CONFIG_FILE"
        cp ${noctaliaConfigToml} "$CONFIG_FILE"
        chmod 644 "$CONFIG_FILE"
        rm -f "$CONFIG_DIR/settings.json"
      '';

      xdg.configFile."noctalia/user-templates/cliamp.toml".text = ''
        accent = "{{ colors.primary.default.hex }}"
        bright_fg = "{{ colors.on_surface.default.hex }}"
        fg = "{{ colors.on_surface_variant.default.hex }}"
        green = "{{ colors.primary.default.hex }}"
        yellow = "{{ colors.secondary.default.hex }}"
        red = "{{ colors.error.default.hex }}"
      '';

      xdg.configFile."noctalia/user-templates/zellij.kdl".text = ''
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
    };
  };
}

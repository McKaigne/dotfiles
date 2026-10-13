{ self, inputs, ... }: {
  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [
        pkgs.glib
        pkgs.dconf
        pkgs.gsettings-desktop-schemas
      ];

      home-manager.users.${user} = {
        imports = [ inputs.noctalia.homeModules.default ];
        programs.noctalia.enable = true;

        xdg.configFile."noctalia/config.toml" = {
          source = ./noctalia.toml;
          force = true;
        };

        xdg.configFile."noctalia/user-templates/ghostty" = {
          text = ''
            background = {{ colors.surface.default.hex }}
            foreground = {{ colors.on_surface.default.hex }}
            cursor-color = {{ colors.primary.default.hex }}
            cursor-text = {{ colors.on_primary.default.hex }}
            selection-background = {{ colors.primary_container.default.hex }}
            selection-foreground = {{ colors.on_primary_container.default.hex }}

            palette = 0={{ colors.surface_container_lowest.default.hex }}
            palette = 1={{ colors.error.default.hex }}
            palette = 2={{ colors.tertiary.default.hex }}
            palette = 3={{ colors.secondary.default.hex }}
            palette = 4={{ colors.primary.default.hex }}
            palette = 5={{ colors.tertiary.default.hex }}
            palette = 6={{ colors.secondary.default.hex }}
            palette = 7={{ colors.on_surface.default.hex }}
            palette = 8={{ colors.outline.default.hex }}
            palette = 9={{ colors.error.default.hex }}
            palette = 10={{ colors.tertiary.default.hex }}
            palette = 11={{ colors.secondary.default.hex }}
            palette = 12={{ colors.primary.default.hex }}
            palette = 13={{ colors.tertiary.default.hex }}
            palette = 14={{ colors.secondary.default.hex }}
            palette = 15={{ colors.on_surface_variant.default.hex }}
          '';
          force = true;
        };

        xdg.configFile."noctalia/user-templates/tmux.conf" = {
          text = ''
            set -g status-style "bg=default,fg={{ colors.on_surface.default.hex }}"
            set -g window-style "bg=default,fg={{ colors.on_surface.default.hex }}"
            set -g window-active-style "bg=default,fg={{ colors.on_surface.default.hex }}"
            set -g pane-border-style "fg={{ colors.surface_container.default.hex }},bg=default"
            set -g pane-active-border-style "fg={{ colors.primary.default.hex }},bg=default"
            set -g popup-border-style "fg={{ colors.primary.default.hex }},bg=default"

            set -g status-left "#[fg={{ colors.tertiary.default.hex }},bold]#{host_short} #[fg={{ colors.outline.default.hex }}]· #[fg={{ colors.primary.default.hex }},bold][#S] #[default]"
            set -g window-status-format "#[fg={{ colors.outline.default.hex }}]#I:#W"
            set -g window-status-current-format "#[fg={{ colors.primary.default.hex }},bold]#I:#W#{?window_zoomed_flag, #[fg={{ colors.error.default.hex }}],}"
          '';
          force = true;
        };
      };
    };
}

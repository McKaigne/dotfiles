{ self, inputs, ... }: {
  flake.nixosModules.ghostty =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.ghostty ];

      home-manager.users.${user} = {
        xdg.configFile."ghostty/config" = {
          text = ''
            font-family = Lilex Nerd Font
            font-size = 14
            font-feature = cv01
            font-feature = cv02
            font-feature = cv09
            font-feature = cv11
            font-feature = cv13
            font-feature = cv15
            font-feature = ss01

            theme = "Catppuccin-Mocha"
            background-opacity = 0.85
            background-blur = true
            window-decoration = false
            cursor-style = block
            shell-integration = detect
          '';
          force = true;
        };

        xdg.configFile."ghostty/themes/Catppuccin-Mocha" = {
          text = ''
            background = #1e1e2e
            foreground = #cdd6f4
            selection-background = #585b70
            selection-foreground = #cdd6f4
            cursor-color = #f5e0dc
            cursor-text = #11111b

            palette = 0=#45475a
            palette = 1=#f38ba8
            palette = 2=#a6e3a1
            palette = 3=#f9e2af
            palette = 4=#89b4fa
            palette = 5=#f5c2e7
            palette = 6=#94e2d5
            palette = 7=#bac2de
            palette = 8=#585b70
            palette = 9=#f38ba8
            palette = 10=#a6e3a1
            palette = 11=#f9e2af
            palette = 12=#89b4fa
            palette = 13=#f5c2e7
            palette = 14=#94e2d5
            palette = 15=#a6adc8
          '';
          force = true;
        };
      };
    };
}

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

            theme = noctalia
            background-opacity = 0.85
            background-blur = true
            window-decoration = false
            cursor-style = block
            shell-integration = detect
          '';
          force = true;
        };

        # Fallback theme for clean bootstrap before Noctalia execution
        xdg.configFile."ghostty/themes/noctalia" = {
          text = ''
            background = #001419
            foreground = #839395
            cursor-color = #29a298
            cursor-text = #ffffff
            selection-background = #002c38
            selection-foreground = #839395

            palette = 0=#001014
            palette = 1=#db302d
            palette = 2=#29a298
            palette = 3=#b28500
            palette = 4=#29a298
            palette = 5=#29a298
            palette = 6=#b28500
            palette = 7=#839395
            palette = 8=#576d74
            palette = 9=#db302d
            palette = 10=#29a298
            palette = 11=#b28500
            palette = 12=#29a298
            palette = 13=#29a298
            palette = 14=#b28500
            palette = 15=#839395
          '';
          force = true;
        };
      };
    };
}

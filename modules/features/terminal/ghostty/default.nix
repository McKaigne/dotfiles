{ self, inputs, ... }: {
  flake.nixosModules.ghostty =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      p = config.palette;
    in
    {
      environment.systemPackages = [ pkgs.ghostty ];

      home-manager.users.${user} = {
        xdg.configFile."ghostty/themes/Catppuccin Mocha" = {
          text = ''
            palette = 0=${p.surface1}
            palette = 1=${p.red}
            palette = 2=${p.green}
            palette = 3=${p.yellow}
            palette = 4=${p.blue}
            palette = 5=${p.pink}
            palette = 6=${p.teal}
            palette = 7=${p.subtext1}
            palette = 8=${p.surface2}
            palette = 9=${p.red}
            palette = 10=${p.green}
            palette = 11=${p.yellow}
            palette = 12=${p.blue}
            palette = 13=${p.pink}
            palette = 14=${p.teal}
            palette = 15=${p.subtext0}
            background = ${p.base}
            foreground = ${p.text}
            cursor-color = ${p.rosewater}
            cursor-text = ${p.crust}
            selection-background = ${p.surface2}
            selection-foreground = ${p.text}
          '';
          force = true;
        };

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

            command = fish

            theme = "Catppuccin Mocha"
            background = ${p.base}
            foreground = ${p.text}

            background-opacity = 0.85
            background-blur = true
            window-decoration = false
            cursor-style = block
            shell-integration = detect
          '';
          force = true;
        };
      };
    };
}

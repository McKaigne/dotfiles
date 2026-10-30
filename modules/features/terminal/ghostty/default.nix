_: {
  flake.nixosModules.ghostty =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      inherit (config) theme;
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
            font-family = ${theme.fonts.mono.name}
            font-size = 13
            adjust-cell-height = 0

            command = ${pkgs.fish}/bin/fish

            theme = "Catppuccin Mocha"
            background = ${p.base}
            foreground = ${p.text}

            background-opacity = ${theme.opacity}
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

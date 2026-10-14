{ self, inputs, ... }: {
  flake.nixosModules.fuzzel =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.fuzzel ];

      home-manager.users.${user} = {
        xdg.configFile."fuzzel/fuzzel.ini" = {
          text = ''
            [main]
            include=~/.config/fuzzel/themes/noctalia
            font=Lilex Nerd Font:size=14
            prompt="➜ "
            lines=12
            width=35
            horizontal-pad=20
            vertical-pad=15
            inner-pad=10
            prefer-no-csd

            [border]
            width=1
            radius=12
          '';
          force = true;
        };

        # Fallback theme for clean bootstrap before Noctalia execution
        xdg.configFile."fuzzel/themes/noctalia" = {
          text = ''
            [colors]
            background=001419e6
            text=839395ff
            match=29a298ff
            selection=002c38ff
            selection-text=839395ff
            selection-match=29a298ff
            border=002c38ff
          '';
          force = true;
        };
      };
    };
}

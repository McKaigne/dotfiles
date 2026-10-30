_: {
  flake.nixosModules.fuzzel =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      inherit (config) theme;
      p = config.palette;
    in
    {
      environment.systemPackages = [ pkgs.fuzzel ];

      home-manager.users.${user} = {
        programs.fuzzel = {
          enable = true;
          settings = {
            main = {
              font = "${theme.fonts.sans.name}:size=14";
              prompt = "➜ ";
              lines = 12;
              width = 35;
              horizontal-pad = 20;
              vertical-pad = 15;
              inner-pad = 10;
              prefer-no-csd = true;
            };
            colors = {
              background = "${p.hex.base}d9";
              text = "${p.hex.text}ff";
              match = "${p.hex.mauve}ff";
              selection = "${p.hex.surface0}ff";
              selection-text = "${p.hex.text}ff";
              selection-match = "${p.hex.mauve}ff";
              border = "${p.hex.mauve}ff";
            };
            border = {
              width = theme.borderWidth;
              inherit (theme) radius;
            };
          };
        };
      };
    };
}

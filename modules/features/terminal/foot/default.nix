{ self, inputs, ... }: {
  flake.nixosModules.foot =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      p = config.palette;
    in
    {
      environment.systemPackages = [ pkgs.foot ];

      home-manager.users.${user} = {
        programs.foot = {
          enable = true;
          server.enable = true;
          settings = {
            main = {
              term = "foot";
              shell = "${pkgs.fish}/bin/fish";
              font = "AtkynsonMono Nerd Font:size=14px";
              dpi-aware = "no";
              pad = "12x12";
            };
            colors = {
              alpha = 0.85;
              background = p.hex.base;
              foreground = p.hex.text;
              regular0 = p.hex.surface1;
              regular1 = p.hex.red;
              regular2 = p.hex.green;
              regular3 = p.hex.yellow;
              regular4 = p.hex.blue;
              regular5 = p.hex.pink;
              regular6 = p.hex.teal;
              regular7 = p.hex.subtext1;
              bright0 = p.hex.surface2;
              bright1 = p.hex.red;
              bright2 = p.hex.green;
              bright3 = p.hex.yellow;
              bright4 = p.hex.blue;
              bright5 = p.hex.pink;
              bright6 = p.hex.teal;
              bright7 = p.hex.subtext0;
            };
          };
        };
      };
    };
}

_: {
  flake.nixosModules.fastfetch =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.fastfetch ];

      home-manager.users.${user} = {
        programs.fastfetch = {
          enable = true;
          settings = {
            logo = {
              type = "small";
              padding = {
                top = 1;
                left = 2;
              };
            };
            display = {
              separator = " ➜ ";
            };
            modules = [
              "title"
              "separator"
              "os"
              "host"
              "kernel"
              "uptime"
              "packages"
              "shell"
              "display"
              "de"
              "wm"
              "terminal"
              "cpu"
              "gpu"
              "memory"
              "break"
              "colors"
            ];
          };
        };
      };
    };
}

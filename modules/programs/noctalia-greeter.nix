{ inputs, ... }:
{
  flake.modules.nixos.noctalia-greeter =
    { config, pkgs, ... }:
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
        {
          services.displayManager.noctalia-greeter = {
            enable = true;
            package = pkgs.noctalia-greeter;
            passwordless-sync-users = [ config.workstation.username ];
            greeter-args = "";
            settings = {
              session = { default = "Umbriel"; last = "Umbriel"; };
              user.default = config.workstation.username;
              appearance = {
                scheme = "Synced";
                password_style = "random";
                font_family = "Maple Mono NF";
              };
              cursor = {
                theme = config.workstation.cursor.theme;
                path = config.workstation.cursor.package;
                size = 24;
              };
              keyboard.layout = "us";
              output.name = config.workstation.display.output;
            };
          };

          systemd.tmpfiles.settings."10-noctalia-greeter"."/var/lib/noctalia-greeter/sync.toml".f =
            {
              user = "greeter";
              group = "greeter";
              mode = "0640";
            };
        }
      ];
    };
}

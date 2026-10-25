{ self, inputs, ... }: {
  flake.nixosModules.nushell =
    { config, pkgs, lib, ... }:
    let
      user = config.mainUser;
      isCompound = cmd: lib.hasInfix "&&" cmd || lib.hasInfix ";" cmd || lib.hasPrefix "-" cmd;
      simpleAliases = lib.filterAttrs (_: cmd: !isCompound cmd) config.workstation.shellAliases;
    in
    {
      environment.systemPackages = [ pkgs.nushell ];

      home-manager.users.${user} = {
        programs.nushell = {
          enable = true;
          shellAliases = simpleAliases;

          extraEnv = ''
            $env.STARSHIP_CONFIG = "/etc/starship.toml"
            $env.EDITOR = "hx"
            $env.VISUAL = "hx"
            $env.BAT_THEME = "Catppuccin Mocha"
            $env.PATH = ($env.PATH | split row (char esep) | prepend [
              $"($env.HOME)/.local/bin"
              $"($env.HOME)/.cargo/bin"
            ])
          '';

          extraConfig = ''
            $env.config = {
              show_banner: false
              edit_mode: 'vi'
            }
          '';
        };
      };
    };
}

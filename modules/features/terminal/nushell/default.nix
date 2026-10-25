{ self, inputs, ... }: {
  flake.nixosModules.nushell =
    { config, pkgs, lib, ... }:
    let
      user = config.mainUser;
      # Nushell aliases must be simple commands; strip compound chains and flags
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

            # Native Nushell commands for compound workstation workflows
            def --env rebuild [] { git -C /etc/nixos add -A; sudo nixos-rebuild switch --flake /etc/nixos }
            def --env rebuildh [] { git -C /etc/nixos add -A; sudo nixos-rebuild switch --flake /etc/nixos#hyde }
            def --env rebuildc [] { git -C /etc/nixos add -A; sudo nixos-rebuild switch --flake /etc/nixos#castor }
            def --env nr [] { git -C /etc/nixos add -A; sudo nixos-rebuild switch --flake /etc/nixos }
            def --env nboot [] { git -C /etc/nixos add -A; sudo nixos-rebuild boot --flake /etc/nixos }
            def --env ntest [] { git -C /etc/nixos add -A; sudo nixos-rebuild test --flake /etc/nixos }
            def --env ncd [] { cd /etc/nixos }
          '';
        };
      };
    };
}

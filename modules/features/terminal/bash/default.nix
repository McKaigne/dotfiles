{ self, inputs, ... }: {
  flake.nixosModules.bash =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      programs.bash = {
        completion.enable = true;
        shellAliases = config.workstation.shellAliases;
      };

      home-manager.users.${user} = {
        programs.bash = {
          enable = true;
          enableCompletion = true;
          shellAliases = config.workstation.shellAliases;
          initExtra = ''
            export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
          '';
        };
      };
    };
}

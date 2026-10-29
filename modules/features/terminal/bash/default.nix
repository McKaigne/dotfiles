{ self, inputs, ... }: {
  flake.nixosModules.bash =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      programs.bash = {
        completion.enable = true;
      };

      home-manager.users.${user} = {
        programs.bash = {
          enable = true;
          enableCompletion = true;
          shellAliases = { };
          initExtra = ''
            export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
            export STARSHIP_CONFIG="/etc/starship.toml"
            eval "$(${pkgs.starship}/bin/starship init bash)"
          '';
        };
      };
    };
}

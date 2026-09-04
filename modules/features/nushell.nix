
{ self, inputs, ... }: {
  # 1. NixOS Module
  flake.nixosModules.nushell = { pkgs, ... }: {
    programs.nushell.enable = true;

    environment.shells = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell
    ];

    users.users.pollux.shell = self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell;

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell
    ];
  };

  # 2. Package & App Wrapper
  perSystem = { pkgs, lib, ... }:
    let
      shellTools = with pkgs; [
        starship
        zoxide
        carapace
        eza
        fzf
        neovim
        direnv
        nix-direnv
        atuin
      ];

      configFile = ./nushell/config.nu;
      envFile = ./nushell/env.nu;
      starshipConfig = ./nushell/starship.toml;

      myNushell = pkgs.symlinkJoin {
        name = "my-nushell";
        paths = [ pkgs.nushell ];
        buildInputs = [ pkgs.makeWrapper ];
        passthru = {
          shellPath = "/bin/nu";
        };
        postBuild = ''
          wrapProgram $out/bin/nu \
            --prefix PATH : ${lib.makeBinPath shellTools} \
            --set-default STARSHIP_CONFIG "${starshipConfig}" \
            --add-flags "--config ${configFile} --env-config ${envFile}"
        '';
      };
    in
    {
      packages.myNushell = myNushell;

      # Allows `nix run .#myNushell`
      apps.myNushell = {
        type = "app";
        program = "${myNushell}/bin/nu";
      };
    };
}

{ self, inputs, ... }: {
  # 1. NixOS Module
  flake.nixosModules.nushell = { pkgs, ... }: {
    programs.nushell.enable = true;

    # Register wrapped nushell as a valid system login shell
    environment.shells = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell
    ];

    # Set as default shell for pollux
    users.users.pollux.shell = self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell;

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell
    ];
  };

  # 2. Package Wrapper
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
        # Tells NixOS where the shell binary lives
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
    };
}

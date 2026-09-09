{ self, inputs, ... }: {
  flake.nixosModules.nushell = { pkgs, ... }: {
    programs.nushell.enable = true;

    environment.shells = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell
    ];

    users.defaultUserShell = self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell;

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell
    ];
  };

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
        helix
        tmux
      ];

      configFile = ../../dotfiles/nushell/config.nu;
      envFile = ../../dotfiles/nushell/env.nu;
      starshipConfig = ../../dotfiles/starship/starship.toml;

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
            --run '[ -f "$HOME/.config/starship/starship.toml" ] && export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml" || export STARSHIP_CONFIG="${starshipConfig}"' \
            --run '[ -f "$HOME/.config/nushell/config.nu" ] || set -- --config "${configFile}" --env-config "${envFile}" "$@"'
        '';
      };
    in
    {
      packages.myNushell = myNushell;

      apps.nushell = {
        type = "app";
        program = "${myNushell}/bin/nu";
        meta.description = "Nushell wrapped with custom CLI utilities and configs";
      };
    };
}
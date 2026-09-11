{ ... }: {
  perSystem = { self', pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "castor-dotfiles-shell";
      nativeBuildInputs = with pkgs; [
        git
        nixfmt
        nixos-rebuild
      ];

      shellHook = ''
        echo "❄ Castor Workstation Flake Environment Active"
      '';
    };

    checks = {
      test-helix = pkgs.runCommand "test-helix" {} ''
        ${self'.packages.helix}/bin/hx --version > $out
      '';

      test-nushell = pkgs.runCommand "test-nushell" {} ''
        ${self'.packages.nushell}/bin/nu -c "echo 'Nushell hermetic wrapper verified'" > $out
      '';

      test-tmux = pkgs.runCommand "test-tmux" {} ''
        ${self'.packages.tmux}/bin/tmux -V > $out
      '';

      test-cava = pkgs.runCommand "test-cava" {} ''
        ${self'.packages.cava}/bin/cava -v > $out
      '';
    };
  };
}
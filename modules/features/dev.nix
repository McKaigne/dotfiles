{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "castor-dotfiles-shell";
      nativeBuildInputs = with pkgs; [
        git
        nixfmt-rfc-style
        nixos-rebuild
      ];

      shellHook = ''
        echo "❄ Castor Workstation Flake Environment Active"
      '';
    };
  };
}
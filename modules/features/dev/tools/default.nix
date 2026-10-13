{ self, inputs, ... }: {
  flake.nixosModules.devTools =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      ghgrabPkg = inputs.ghgrab.packages.${system}.default;
    in
    {
      environment.systemPackages = with pkgs; [
        hyperfine
        tokei
        glow
        lazydocker
        ast-grep
        ghgrabPkg
      ];
    };
}

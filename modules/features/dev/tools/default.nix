{ self, inputs, ... }: {
  flake.nixosModules.devTools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      hyperfine
      tokei
      glow
      lazydocker
    ];
  };
}

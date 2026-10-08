{ self, inputs, ... }: {
  flake.nixosModules.dev = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      godot_4
      hyperfine
      tokei
      glow
      lazydocker
    ];
  };
}

{ self, inputs, ... }: {
  flake.nixosModules.dev = { pkgs, ... }: {
    programs.git = {
      enable = true;
      config = {
        user = {
          name = "McKaigne";
          email = "abellorchristian2007@gmail.com";
        };
        init.defaultBranch = "main";
      };
    };

    environment.systemPackages = with pkgs; [
      godot_4
      hyperfine
      tokei
      glow
      lazydocker
    ];
  };
}

{ self, inputs, ... }: {
  flake.nixosModules.git = { pkgs, ... }: {
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
  };
}

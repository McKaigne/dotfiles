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
        credential = {
          "https://github.com".helper = "!gh auth git-credential";
          "https://gist.github.com".helper = "!gh auth git-credential";
        };
        safe.directory = [ "/etc/nixos" ];
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "Catppuccin Mocha";
          side-by-side = false;
        };
        merge.conflictstyle = "zdiff3";
        diff.colorMoved = "default";
      };
    };
  };
}

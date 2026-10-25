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
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "Catppuccin Mocha";
          side-by-side = false;
          plus-style = "syntax #313244";
          minus-style = "syntax #313244";
          plus-emph-style = "syntax #45475a";
          minus-emph-style = "syntax #45475a";
          line-numbers-left-style = "#585b70";
          line-numbers-right-style = "#585b70";
          line-numbers-zero-style = "#45475a";
          zero-style = "syntax";
          whitespace-error-style = "#f38ba8 reverse";
        };
        merge.conflictstyle = "zdiff3";
        diff.colorMoved = "default";
      };
    };
  };
}

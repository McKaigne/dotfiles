{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs; # VERY IMPORTANT
      settings =
        if builtins.pathExists ./noctalia.json then
          let
            json = builtins.fromJSON (builtins.readFile ./noctalia.json);
          in
          if json ? settings then json.settings else json
        else
          {
            bar.position = "top";
            theme.dark = true;
          };
    };
  };
}

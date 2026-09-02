{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = {
        bar = {
          position = "top";
          height = 36;
        };
        theme = {
          dark = true;
          rounding = 12;
        };
      };
    };
  };
}

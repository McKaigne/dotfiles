
{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.noctalia-shell = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      outOfStoreConfig = "/home/pollux/.config/noctalia/";
      settings = {
        bar = {
          position = "top";
          height = 36;
        };
        theme = {
          dark = false;
          rounding = 12;
        };
      };
    };
  };
}

{ ... }: {
  flake.nixosModules.user = { lib, ... }: {
    options.mainUser = lib.mkOption {
      type = lib.types.str;
      default = "pollux";
      description = "Primary workstation user account";
    };
  };
}

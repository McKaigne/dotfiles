{ lib, ... }: {
  flake.nixosModules.user = { ... }: {
    options.mainUser = lib.mkOption {
      type = lib.types.str;
      default = "pollux";
      description = "Primary workstation user account";
    };
  };
}
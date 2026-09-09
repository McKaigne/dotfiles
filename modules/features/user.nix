{ lib, ... }:
let
  userModule = { ... }: {
    options.mainUser = lib.mkOption {
      type = lib.types.str;
      default = "pollux";
      description = "Primary workstation user account";
    };
  };
in
{
  flake.nixosModules.user = userModule;
  flake.nixosModules.castorConfiguration = userModule;
}
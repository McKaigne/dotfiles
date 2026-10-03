{ config, lib, inputs, ... }:
let
  user = config.mainUser;
in
{
  options.mainUser = lib.mkOption {
    type = lib.types.str;
    default = "pollux";
    description = "Primary workstation user account";
  };

  config = {
    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "uinput" ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      extraSpecialArgs = { inherit inputs; };
      users.${user} = {
        home.stateVersion = "25.05";
        programs.home-manager.enable = true;
      };
    };
  };
}

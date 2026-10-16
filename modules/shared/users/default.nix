# Shared: User Accounts & Home Manager Entrypoint
{ self, inputs, ... }: {
  flake.nixosModules.users =
    { config, lib, pkgs, ... }:
    let
      user = config.mainUser;
      avatarSrc = ../../../avatar.jpg;
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
          extraGroups = [
            "wheel"
            "networkmanager"
            "video"
            "audio"
            "input"
            "uinput"
            "render"
            "i2c"
          ];
        };

        systemd.tmpfiles.rules = [
          "d /var/lib/AccountsService/icons 0755 root root -"
          "d /var/lib/AccountsService/users 0755 root root -"
          "C+ /var/lib/AccountsService/icons/${user} 0644 root root - ${avatarSrc}"
          "f+ /var/lib/AccountsService/users/${user} 0644 root root - [User]\nIcon=/var/lib/AccountsService/icons/${user}\nSession=\nXSession=\n"
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "hm-backup";
          extraSpecialArgs = { inherit inputs self; };
          users.${user} = {
            home.stateVersion = "25.05";
            programs.home-manager.enable = true;

            home.file.".face" = {
              source = avatarSrc;
              force = true;
            };
            home.file.".face.icon" = {
              source = avatarSrc;
              force = true;
            };
          };
        };
      };
    };
}

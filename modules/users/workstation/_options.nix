{lib, ...}: let
  desktops = import ../../desktops/_metadata.nix;
in {
  options.workstation = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Primary user account name.";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Networking hostname.";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "NixOS / home-manager stateVersion";
    };

    system = lib.mkOption {
      type = lib.types.str;
      description = "Nixpkgs system string";
    };

    desktop = lib.mkOption {
      type = lib.types.enum desktops.names;
      description = "Active compositor / desktop session";
    };

    screenWidth = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Logical width of the main output; lets the bar match a lone centered window.";
    };

    git = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Git user.name";
      };

      email = lib.mkOption {
        type = lib.types.str;
        description = "Git user.email";
      };

      signingKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "OpenPGP signing key id; commits are signed only when set";
      };
    };
  };
}

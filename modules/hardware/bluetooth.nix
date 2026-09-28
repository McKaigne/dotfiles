{ ... }: {
  flake.nixosModules.bluetooth = { ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          JustWorksRepairing = "always";
        };
        Input = {
          ClassicBondedOnly = false;
        };
      };
    };
    services.blueman.enable = true;

    services.udev.extraRules = ''
      KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="*[Ff]low84*", SYMLINK+="input/by-id/lofree-flow84", TAG+="uaccess"
      KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="*[Ll]ofree*", SYMLINK+="input/by-id/lofree-flow84", TAG+="uaccess"
    '';
  };
}

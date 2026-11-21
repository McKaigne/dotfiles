{ inputs, config, ... }:
{
  flake.modules.nixos.desktop-niri =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ config.flake.modules.homeManager.desktop-niri ];
      imports = [ inputs.niri.nixosModules.niri ];

      niri-flake.cache.enable = true;
      programs.niri = {
        enable = true;
        package = pkgs.niri;
      };

      systemd.user.services.niri-flake-polkit.enable = false;

      environment.systemPackages = with pkgs; [
        xwayland-satellite
        ddcutil
        wtype
        grim
        slurp
      ];
    };
}

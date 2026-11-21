{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos."desktop-umbriel" = {pkgs, ...}: {
    home-manager.sharedModules = [config.flake.modules.homeManager."desktop-umbriel"];
    imports = [
      inputs.umbriel.nixosModules.default
    ];

    programs.umbriel.enable = true;

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    environment.systemPackages = with pkgs; [
      wtype
      grim
      slurp
      brightnessctl
    ];
  };
  flake.modules.homeManager."desktop-umbriel" = {
    programs.umbriel.enable = true;
    imports = [inputs.umbriel.homeModules.default];
  };
}

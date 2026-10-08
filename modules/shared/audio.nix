{ self, inputs, ... }: {
  flake.nixosModules.audio = { config, pkgs, ... }:
  let
    user = config.mainUser;
  in
  {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    hardware.firmware = with pkgs; [
      sof-firmware
      alsa-firmware
    ];

    home-manager.users.${user} = {
      services.easyeffects.enable = true;
    };

    environment.systemPackages = with pkgs; [
      easyeffects
      pavucontrol
      cava
    ];
  };
}

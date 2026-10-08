{ self, inputs, ... }: {
  flake.nixosModules.media = { config, pkgs, ... }:
  let
    user = config.mainUser;
  in
  {
    environment.systemPackages = with pkgs; [
      imv
      parabolic
      mpv
    ];

    home-manager.users.${user} = {
      xdg.configFile."mpv/mpv.conf".text = ''
        vo=gpu-next
        gpu-context=wayland
        hwdec=auto-safe
      '';
    };
  };
}

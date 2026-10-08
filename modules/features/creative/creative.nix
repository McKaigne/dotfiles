{ self, inputs, ... }: {
  flake.nixosModules.creative = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      blender
      kdePackages.kdenlive
      krita
    ];

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-vaapi
        obs-vkcapture
        obs-pipewire-audio-capture
      ];
    };
  };
}

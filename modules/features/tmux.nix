{ self, inputs, ... }: {
  flake.nixosModules.tmux = { pkgs, ... }: {
    programs.tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        dotbar
      ];
    };
  };
}
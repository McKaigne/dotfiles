{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    delta
    lazygit
    gh
    hyperfine
    tokei
    glow
    lazydocker
  ];
}

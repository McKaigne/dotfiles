{ pkgs, ... }: {
  environment.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    NNN_OPTS = "aep";
  };

  environment.systemPackages = with pkgs; [
    tree
    bottom
    fetch
    bat
    eza
    dust
    gdu
    procs
    tealdeer
    trippy

    ripgrep
    fd
    findutils
    jq
    jnv
    sd
    xh
    curl

    libreoffice-stable
    yazi
    nnn
    aria2
    p7zip
    unrar

    (pkgs.antigravity-cli or (pkgs.writeShellScriptBin "agy" ''
      if command -v antigravity-cli &>/dev/null; then
        exec antigravity-cli "$@"
      else
        exec nix run "github:antigravity-cli/antigravity" -- "$@"
      fi
    ''))
  ];
}

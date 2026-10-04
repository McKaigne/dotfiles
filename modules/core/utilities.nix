{ pkgs, ... }: {
  environment.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    NNN_OPTS = "aep";
  };

  environment.systemPackages = with pkgs; [
    # Terminal Navigation & Process Monitoring
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

    # Data Processing & Text Transformation
    ripgrep
    fd
    findutils
    jq
    jnv
    sd
    xh
    curl

    # Applications & Archive Tools
    yazi
    nnn
    aria2
    p7zip
    unrar

    # Custom Script Wrappers
    (pkgs.antigravity-cli or (pkgs.writeShellScriptBin "agy" ''
      if command -v antigravity-cli &>/dev/null; then
        exec antigravity-cli "$@"
      else
        exec nix run "github:antigravity-cli/antigravity" -- "$@"
      fi
    ''))
  ];
}

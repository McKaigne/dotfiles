{ pkgs, lib, ... }: {
  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NNN_OPTS = "aep";
  };

  environment.systemPackages = with pkgs; [
    # Terminal Navigation & Process Monitoring
    tree
    btop
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

    # Transfer, Sync & Archive Tools
    yazi
    nnn
    aria2
    p7zip
    unrar
    rsync
  ] ++ lib.optional (pkgs ? ghgrab) pkgs.ghgrab
    ++ lib.optional (pkgs ? lazyrsync) pkgs.lazyrsync
    ++ lib.optional (pkgs ? antigravity-cli) pkgs.antigravity-cli;
}

_: {
  flake.nixosModules.devTools =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        hyperfine
        tokei
        glow
        lazydocker
        ast-grep
        lazyrsync
        lazyssh
        usbtree
        linecast
        claude-code
        whois
        dnsutils
      ];
    };
}

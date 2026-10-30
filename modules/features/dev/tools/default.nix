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
        codex
        herdr
        pi-coding-agent
        whois
        dnsutils
      ];
    };
}

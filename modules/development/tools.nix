{
  flake.modules.homeManager.development =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        just
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
        devenv
        nodejs_22
        (python3.withPackages (ps: [ ps.evdev ]))
        evtest
      ];
    };
}

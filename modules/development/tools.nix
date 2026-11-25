{
  flake.modules.homeManager.development = {pkgs, ...}: {
    home.packages = with pkgs; [
      just
      hyperfine
      tokei
      lazydocker
      ast-grep
      lazyrsync
      lazyssh
      usbtree
      linecast
      # AI coding agents
      claude-code
      codex
      whois
      dnsutils
      devenv
      nodejs_22
      evtest
    ];
  };
}

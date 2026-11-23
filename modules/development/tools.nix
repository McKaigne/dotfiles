{
  flake.modules.homeManager.development = {pkgs, ...}: {
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
      # AI coding agents (Emacs's adapters for them are in its own tools)
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

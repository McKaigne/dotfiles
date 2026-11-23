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
      # AI coding agents, and the adapters that let Emacs's agent-shell
      # drive them
      claude-code
      codex
      claude-agent-acp
      codex-acp
      whois
      dnsutils
      devenv
      nodejs_22
      evtest
    ];
  };
}

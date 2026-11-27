{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.cli = {pkgs, ...}: {
    home-manager.sharedModules = [flakeConfig.flake.modules.homeManager.cli];
    environment.systemPackages = with pkgs; [
      psmisc
      tree
      eza
      dysk
      silicon
      tealdeer
      dust
      procs
      ripgrep
      fd
      jq
      jnv
      sd
      xh
      nnn
      vivid
      repomix
      aria2
      p7zip
      unrar
      unzip
      wget
    ];
  };

  flake.modules.homeManager.cli = {
    config,
    lib,
    pkgs,
    ...
  }: let
    fzfTheme = "${config.xdg.configHome}/fzf/noctalia";
  in {
    # Noctalia renders the colours (noctalia/config/templates.nix).
    home.sessionVariables.FZF_DEFAULT_OPTS_FILE = fzfTheme;

    # fzf refuses to start if the options file is missing; seed it until
    # Noctalia's first render.
    home.activation.seedFzfTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      theme=${lib.escapeShellArg fzfTheme}
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$theme")"
      if [ ! -f "$theme" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
        printf -- '--color=bg:-1,preview-bg:-1,gutter:-1\n' > "$theme"
      fi
    '';

    programs = {
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        defaultCommand = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        fileWidget = {
          command = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
          options = ["--preview '${pkgs.bat}/bin/bat -n --color=always --line-range :500 {}'" "--preview-window=right:60%:wrap"];
        };
        changeDirWidget = {
          command = "${pkgs.fd}/bin/fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
          options = ["--preview '${pkgs.eza}/bin/eza --tree --level=2 --color=always {} | head -200'" "--preview-window=right:60%:wrap"];
        };
        historyWidget.command = "";
        defaultOptions = [
          "--height=50%"
          "--layout=reverse"
          "--border=none"
          "--info=inline"
          "--prompt='➜ '"
          "--pointer='▶'"
          "--marker='✓'"
        ];
      };

      carapace = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };

      atuin = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        settings = {
          style = "compact";
          inline_height = 20;
          show_preview = true;
          update_check = false;
        };
      };

      bat = {
        # Noctalia's bat template owns ~/.config/bat/config; BAT_THEME is set globally.
        enable = true;
      };
    };

    xdg.configFile."repomix/repomix.config.json" = {
      text = builtins.toJSON {
        output = {
          filePath = "/tmp/repomix-output.xml";
          style = "xml";
          copyToClipboard = true;
          showLineNumbers = false;
          topFilesLength = 5;
        };
        ignore = {
          useGitignore = true;
          useDefaultPatterns = true;
          customPatterns = [
            "**/flake.lock"
            "**/result"
            "**/node_modules/**"
            "**/target/**"
            "**/*cache*"
            "**/*Cache*"
            "**/*.log"
            "**/*.sqlite*"
            "**/*.db*"
            "**/*.bin"
            "**/*.dat"
            "**/*asar*"
            "**/BraveSoftware/**"
            "**/brave/**"
            "**/chromium/**"
            "**/floorp/**"
            "**/librewolf/**"
            "**/mozilla/**"
            "**/google-chrome/**"
            "**/net.imput.helium/**"
            "**/Bitwarden/**"
            "**/obsidian/**"
            "**/Ferdium/**"
            "**/obs-studio/**"
            "**/*credential*"
            "**/*token*"
            "**/*secret*"
            "**/*.key"
            "**/gh/hosts.yml"
            "**/*.jpg"
            "**/*.png"
            "**/*.webp"
            "**/*.wasm"
          ];
        };
        security.enableSecurityCheck = true;
      };
      force = true;
    };
  };
}

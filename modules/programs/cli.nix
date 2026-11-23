{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.cli = {pkgs, ...}: {
    home-manager.sharedModules = [flakeConfig.flake.modules.homeManager.cli];
    environment.systemPackages = with pkgs; [
      carapace
      psmisc
      delta
      gh
      tree
      bat
      eza
      dysk
      silicon
      tealdeer
      dust
      procs
      ripgrep
      fd
      findutils
      jq
      jnv
      sd
      xh
      curl
      nnn
      gawk
      vivid
      repomix
      aria2
      p7zip
      unrar
      rsync
      unzip
      wget
    ];
  };

  flake.modules.homeManager.cli = {pkgs, ...}: {
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
        fileWidget.command = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
        changeDirWidget.command = "${pkgs.fd}/bin/fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
        historyWidget.command = "";
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
            "**/obsidian/**"
            "**/Ferdium/**"
            "**/obs-studio/**"
            "**/*credential*"
            "**/*token*"
            "**/*secret*"
            "**/*.key"
            "**/.gh/**"
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

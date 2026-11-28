{
  flake.modules.homeManager.emacs = {
    config,
    lib,
    pkgs,
    ...
  }: let
    emacs = config.programs.emacs.finalPackage;
    emacsDir = "${config.xdg.configHome}/emacs";
    style = import ../../appearance/_style.nix;
    orgDir = "${config.home.homeDirectory}/Areas/Org";
    ghostelDir = "${config.xdg.dataHome}/emacs/ghostel";
    ghostelModule = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).ghostel.module;
    tools = pkgs.buildEnv {
      name = "emacs-tools";
      pathsToLink = ["/bin"];
      paths = with pkgs; [
        git
        fd
        ripgrep
        direnv
        cmark-gfm
        wl-clipboard
        fish-lsp
      ];
    };
    textTypes = [
      "text/plain"
      "text/markdown"
      "text/org"
      "text/x-nix"
      "text/x-csrc"
      "text/x-chdr"
      "text/x-c++src"
      "text/x-c++hdr"
      "text/x-python"
      "text/x-shellscript"
      "application/x-shellscript"
      "text/x-cmake"
      "text/x-makefile"
      "text/x-log"
      "text/csv"
      "application/xml"
      "application/json"
      "application/toml"
      "application/yaml"
      "application/x-yaml"
      "text/x-yaml"
      "text/x-toml"
      "text/x-ini"
      "text/x-tex"
      "text/x-diff"
      "text/x-patch"
      "text/x-readme"
      "text/x-emacs-lisp"
      "text/x-go"
      "text/rust"
      "text/x-rust"
      "text/x-java"
      "text/x-kotlin"
      "text/x-lua"
      "text/x-ruby"
      "application/x-ruby"
      "text/x-perl"
      "application/x-perl"
      "text/x-php"
      "application/x-php"
      "text/x-haskell"
      "text/x-julia"
      "text/x-zig"
      "text/x-sql"
      "application/sql"
      "text/x-gdscript"
      "application/x-gdscript"
      "text/x-glsl"
      "text/css"
      "text/javascript"
      "application/javascript"
      "text/x-typescript"
      "application/x-typescript"
      "text/x-dockerfile"
      "text/x-meson"
      "application/x-desktop"
      "application/x-zerosize"
    ];
    guard = ''
      if [ -n "''${EMACS_DAEMON_CHILD-}" ] && [ -z "''${INSIDE_EMACS-}" ]; then
        echo "''${0##*/}: run from inside Emacs without a terminal, so it would wait on itself; use M-& or a terminal" >&2
        exit 1
      fi
    '';
    launcher = pkgs.writeShellScriptBin "emacs" ''
      args=()
      for arg in "$@"; do
        case "$arg" in
          --batch|-Q|-q|--no-init-file|--daemon*|--fg-daemon*|--version|--help)
            exec ${emacs}/bin/emacs "$@"
            ;;
          -nw|--no-window-system) ;;
          *) args+=("$arg") ;;
        esac
      done
      ${guard}
      exec ${emacs}/bin/emacsclient --create-frame "''${args[@]}"
    '';
    client = pkgs.writeShellScriptBin "emacsclient" ''
      args=()
      for arg in "$@"; do
        case "$arg" in
          -e|--eval|--eval=*|-V|--version|-H|--help)
            exec ${emacs}/bin/emacsclient "$@"
            ;;
          -t|-nw|--tty|-c|--create-frame) ;;
          *) args+=("$arg") ;;
        esac
      done
      ${guard}
      exec ${emacs}/bin/emacsclient --create-frame "''${args[@]}"
    '';
  in {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages = epkgs:
        with epkgs; [
          meow
          vertico
          orderless
          consult
          corfu
          cape
          marginalia
          embark
          embark-consult
          nerd-icons
          nerd-icons-completion
          nerd-icons-corfu
          yasnippet
          avy
          ace-window
          vundo
          helpful
          gcmh
          jinx
          apheleia
          eldoc-box
          flyover
          treesit-fold
          envrc
          magit
          diff-hl
          ghostel
          dirvish
          dashboard
          doom-modeline
          hl-todo
          rainbow-delimiters
          pulsar
          indent-bars
          spacious-padding
          breadcrumb
          ligature
          olivetti
          org
          org-modern
          org-appear
          org-tidy
          org-roam
          consult-org-roam
          org-super-agenda
          nix-ts-mode
          markdown-mode
          fish-mode
          templ-ts-mode
          (treesit-grammars.with-grammars (g:
            with g; [
              tree-sitter-c
              tree-sitter-cpp
              tree-sitter-rust
              tree-sitter-python
              tree-sitter-go
              tree-sitter-gomod
              tree-sitter-templ
              tree-sitter-html
              tree-sitter-nix
              tree-sitter-bash
              tree-sitter-yaml
              tree-sitter-toml
              tree-sitter-json
              tree-sitter-cmake
            ]))
        ];
    };

    services.emacs = {
      enable = true;
      package = emacs;
      startWithUserSession = "graphical";
      socketActivation.enable = true;
    };

    home.packages = [
      pkgs.ghostty.terminfo
      (lib.hiPrio launcher)
      (lib.hiPrio client)
      tools
    ];

    xdg.desktopEntries = {
      emacs = {
        name = "Emacs";
        genericName = "Text Editor";
        exec = "${lib.getExe launcher} %F";
        icon = "emacs";
        categories = ["Development" "TextEditor"];
        mimeType = textTypes;
      };
      emacsclient = {
        name = "Emacs (Client)";
        exec = "${lib.getExe launcher} %F";
        noDisplay = true;
      };
      emacs-mail = {
        name = "Emacs (Mail)";
        exec = "${lib.getExe launcher} %u";
        noDisplay = true;
      };
      emacsclient-mail = {
        name = "Emacs (Mail, Client)";
        exec = "${lib.getExe launcher} %u";
        noDisplay = true;
      };
    };
    xdg.mimeApps.defaultApplications = lib.genAttrs textTypes (_: "emacs.desktop");

    xdg.dataFile = {
      "emacs/ghostel/ghostel-module.so".source = "${ghostelModule}/ghostel-module.so";
      "emacs/ghostel/ghostel-module.version".source = "${ghostelModule}/ghostel-module.version";
    };

    xdg.configFile = {
      "enchant/hunspell".source = "${pkgs.hunspellDicts.en_US}/share/hunspell";
      "emacs/init.el" = {
        source = ./init.el;
        force = true;
      };
      "emacs/early-init.el" = {
        source = ./early-init.el;
        force = true;
      };
      "emacs/lisp" = {
        source = ./lisp;
        recursive = true;
        force = true;
      };
      "emacs/splash.png".source = ./splash.png;
      "emacs/paths.el".text = ''
        ;;; paths.el -*- lexical-binding: t -*-
        (defvar nixmacs-tools-directory "${tools}/bin")
        (defvar nixmacs-config-source "/etc/nixos/modules/programs/emacs/")
        (defvar nixmacs-keybindings-file "/etc/nixos/modules/programs/emacs/org/keybindings.org")
        (defvar nixmacs-org-directory "${orgDir}/")
        (defvar nixmacs-ghostel-module-directory "${ghostelDir}/")
        (defvar nixmacs-font "${style.font}")
        (defvar nixmacs-glass ${toString (builtins.floor (style.opacity * 100))})
      '';
    };

    home.activation.seedEmacsTheme =
      lib.hm.dag.entryBetween
      ["reloadSystemd"]
      ["linkGeneration"]
      ''
        themeDir=${lib.escapeShellArg "${emacsDir}/themes"}
        $DRY_RUN_CMD mkdir -p "$themeDir"
        if [ ! -f "$themeDir/noctalia-theme.el" ]; then
          $DRY_RUN_CMD cp ${./themes/noctalia-theme.el} "$themeDir/noctalia-theme.el"
        fi
        $DRY_RUN_CMD chmod u+w "$themeDir/noctalia-theme.el"
      '';

    home.activation.seedEmacsOrg = lib.hm.dag.entryAfter ["writeBoundary"] ''
      orgDir=${lib.escapeShellArg orgDir}
      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        mkdir -p "$orgDir/roam" "$orgDir/journal"
        [ -f "$orgDir/tasks.org" ] || install -m 0644 ${./org/tasks.org} "$orgDir/tasks.org"
      fi
    '';
  };
}

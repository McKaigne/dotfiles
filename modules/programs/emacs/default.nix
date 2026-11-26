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
        emacs-lsp-booster
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
      extraPackages = epkgs: let
        eglot-booster = epkgs.melpaBuild {
          pname = "eglot-booster";
          version = "0-unstable-2025-07-16";
          src = pkgs.fetchFromGitHub {
            owner = "jdtsmith";
            repo = "eglot-booster";
            rev = "510f579409627c333ef0e9157db713b1004da842";
            hash = "sha256-HhWR40j/WFcorp8QttXtOz5yxL1B4JUXL+9IuNpoND0=";
          };
        };
        knockknock = epkgs.melpaBuild {
          pname = "knockknock";
          version = "0.3.0-unstable-2026-01-07";
          src = pkgs.fetchFromGitHub {
            owner = "konrad1977";
            repo = "knockknock";
            rev = "0920b9b390d4b4cc0818574e115d87eb245a41b5";
            hash = "sha256-hTkXfXMIEL4GtZV177/6uFybdmH+zxwsDnaXSXvG4hs=";
          };
          packageRequires = with epkgs; [posframe nerd-icons];
        };
      in
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
          posframe
          knockknock
          yasnippet
          avy
          ace-window
          vundo
          helpful
          gcmh
          jinx
          apheleia
          eldoc-box
          eglot-booster
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
          zoom
          indent-bars
          spacious-padding
          breadcrumb
          ligature
          olivetti
          org
          org-modern
          org-appear
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
        (defvar my-tools-directory "${tools}/bin")
        (defvar my-config-source "/etc/nixos/modules/programs/emacs/")
        (defvar my-keybindings-file "/etc/nixos/modules/programs/emacs/org/keybindings.org")
        (defvar my-org-directory "${orgDir}/")
        (defvar my-ghostel-module-directory "${ghostelDir}/")
        (defvar my-font "${style.font}")
        (defvar my-glass ${toString (builtins.floor (style.opacity * 100))})
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

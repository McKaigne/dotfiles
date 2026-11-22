# Ly-sec's Emacs (meow, vertico/corfu, eglot, magit, org-roam) as a GUI:
# pgtk for a real translucent background (Umbriel blurs behind it), themed
# live by Noctalia's emacs template (themes/ is where it writes and the
# fallback seed). `emacs`, `emacsclient` and Super+D all open a GUI frame on
# one daemon, started on first use so it inherits the Wayland session.
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
    # In Areas so Syncthing carries it to the other machine.
    orgDir = "${config.home.homeDirectory}/Areas/Org";
    tools = pkgs.buildEnv {
      name = "emacs-tools";
      pathsToLink = ["/bin"];
      # Language servers and formatters are on PATH (development/languages.nix);
      # these are what this config itself calls.
      paths = with pkgs; [
        git
        fd
        ripgrep
        direnv
        cmark-gfm
        wl-clipboard
        emacs-lsp-booster
      ];
    };
    # Every way in opens a GUI frame on the one daemon (started on first use,
    # inheriting the Wayland session); the terminal versions are not used.
    # Batch/daemon/info flags reach real Emacs; `emacsclient -e` (Noctalia's
    # theme reload) passes through without opening a frame.
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
      exec ${emacs}/bin/emacsclient --create-frame --alternate-editor="" "''${args[@]}"
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
      exec ${emacs}/bin/emacsclient --create-frame --alternate-editor="" "''${args[@]}"
    '';
  in {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages = epkgs:
        with epkgs; [
          meow
          undo-fu-session
          vertico
          orderless
          marginalia
          consult
          corfu
          cape
          nerd-icons
          nerd-icons-completion
          nerd-icons-ibuffer
          doom-modeline
          nerd-icons-corfu
          treemacs
          treemacs-nerd-icons
          dirvish
          envrc
          nix-mode
          apheleia
          magit
          blamer
          diff-hl
          hl-todo
          rainbow-delimiters
          markdown-mode
          org-modern
          org-appear
          org-roam
          ligature
          meow-tree-sitter
          vterm
          vterm-toggle
          yasnippet
          yasnippet-snippets
          eglot-booster
          helpful
          # Tree-sitter grammars for the languages in use (see
          # development/languages.nix); Emacs has modes for each of these.
          (treesit-grammars.with-grammars (g:
            with g; [
              tree-sitter-c
              tree-sitter-cpp
              tree-sitter-rust
              tree-sitter-python
              tree-sitter-julia
              tree-sitter-haskell
              tree-sitter-html
              tree-sitter-css
              tree-sitter-json
              tree-sitter-javascript
              tree-sitter-typescript
              tree-sitter-tsx
              tree-sitter-go
              tree-sitter-gomod
              tree-sitter-templ
              tree-sitter-kotlin
              tree-sitter-dart
              tree-sitter-bash
              tree-sitter-yaml
              tree-sitter-toml
              tree-sitter-cmake
              tree-sitter-dockerfile
              tree-sitter-typst
            ]))
          haskell-ts-mode
          julia-ts-mode
          kotlin-ts-mode
          dart-mode
          typst-ts-mode
        ];
    };

    home.packages = [
      (lib.hiPrio launcher)
      (lib.hiPrio client)
      tools
    ];

    # One launcher entry, through the same client; the package's own entries
    # (standalone Emacs, and a client with X11-only flags) are hidden.
    xdg.desktopEntries = {
      emacs = {
        name = "Emacs";
        genericName = "Text Editor";
        exec = "${lib.getExe launcher} %F";
        icon = "emacs";
        categories = ["Development" "TextEditor"];
        mimeType = ["text/plain"];
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

    xdg.configFile = {
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
      "emacs/paths.el".text = ''
        ;;; paths.el -*- lexical-binding: t -*-
        (defvar lysec-tools-directory "${tools}/bin")
        (defvar lysec-keybindings-file "/etc/nixos/modules/programs/emacs/org/keybindings.org")
        (defvar lysec-org-directory "${orgDir}/")
        ;; Background opacity (appearance/_style.nix); text stays solid.
        (defvar lysec-glass ${toString (builtins.floor (style.opacity * 100))})
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
        mkdir -p "$orgDir/notes" "$orgDir/journal"
        for f in inbox tasks; do
          [ -f "$orgDir/$f.org" ] || install -m 0644 ${./org}/$f.org "$orgDir/$f.org"
        done
      fi
    '';
  };
}

# Ly-sec's Emacs (meow, vertico/corfu, eglot, magit, org-roam) as a GUI:
# pgtk for a real translucent background (Umbriel blurs behind it), themed
# live by Noctalia's emacs template (themes/ is where it writes and the
# fallback seed). The daemon is Home Manager's services.emacs, started with
# the graphical session (and by its socket if it was stopped); `emacs`,
# `emacsclient` and Super+D all open a GUI frame on it.
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
        # Centaur's spell checking, GitHub preview and fish language server.
        (aspellWithDicts (d: [d.en]))
        python3Packages.grip
        fish-lsp
      ];
    };
    # Every way in opens a GUI frame on the daemon; the terminal versions are
    # not used. Batch/daemon/info flags reach real Emacs; `emacsclient -e`
    # (Noctalia's theme reload) passes through without opening a frame.
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
      exec ${emacs}/bin/emacsclient --create-frame "''${args[@]}"
    '';
  in {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages = epkgs:
        with epkgs; [
          meow
          undo-fu-session
          meow-tree-sitter
          # The look: mode line, dashboard, icons, floating menus.
          doom-modeline
          doom-themes # only its visual bell (ui.el); the theme is Noctalia's
          dashboard
          page-break-lines
          nerd-icons
          nerd-icons-completion
          nerd-icons-corfu
          nerd-icons-ibuffer
          posframe
          vertico-posframe
          which-key-posframe
          transient-posframe
          ultra-scroll
          default-text-scale
          mixed-pitch
          ligature
          transwin
          gcmh
          helpful
          # Completion (completion.el)
          vertico
          orderless
          marginalia
          consult
          consult-dir
          consult-flyspell
          consult-yasnippet
          embark
          embark-consult
          corfu
          cape
          yasnippet
          yasnippet-snippets
          yasnippet-capf
          # Editing (editing.el)
          avy
          avy-zap
          link-hint
          anzu
          beginend
          drag-stuff
          ialign
          iedit
          expand-region
          multiple-cursors
          smart-region
          hungry-delete
          mwim
          vundo
          goto-chg
          kirigami
          sudo-edit
          easy-kill
          browse-kill-ring
          wgrep
          # Highlighting (highlight.el)
          symbol-overlay
          region-occurrences-highlighter
          indent-bars
          colorful-mode
          rainbow-delimiters
          hl-todo
          consult-todo
          diff-hl
          pulsar
          goggles
          # Windows (window.el)
          ace-window
          popper
          # Files, buffers, projects (files.el)
          dirvish
          dired-quick-sort
          dired-gitignore
          dired-rsync
          diredfl
          ibuffer-vc
          treemacs
          treemacs-nerd-icons
          treemacs-magit
          treemacs-tab-bar
          project-x
          # Git (vc.el)
          magit
          magit-todos
          git-timemachine
          git-messenger
          browse-at-remote
          git-modes
          blamer
          # Shells (shell.el)
          eshell-prompt-extras
          xterm-color
          ghostel
          popterm
          # Development (development.el, langs.el)
          envrc
          apheleia
          eglot-booster
          consult-eglot
          flyover
          dape
          eldoc-mouse
          quickrun
          highlight-defined
          macrostep
          nix-mode
          haskell-ts-mode
          julia-ts-mode
          kotlin-ts-mode
          dart-mode
          typst-ts-mode
          go-gen-test
          go-fill-struct
          gotest
          rust-mode
          ron-mode
          flymake-ruff
          inf-ruby
          yard-mode
          ruby-refactor
          yari
          rspec-mode
          alchemist
          elixir-ts-mode
          scss-mode
          coffee-mode
          web-mode
          add-node-modules-path
          haml-mode
          php-mode
          restclient
          cask-mode
          cmake-mode
          csv-mode
          cue-sheet-mode
          lua-mode
          v-mode
          vimrc-mode
          powershell
          mermaid-ts-mode
          scala-ts-mode
          swift-ts-mode
          protobuf-mode
          fish-mode
          # Notes (notes.el)
          org-modern
          org-appear
          org-roam
          org-roam-ui
          org-rich-yank
          toc-org
          org-preview-html
          dslide
          ox-gfm
          ob-go
          ob-powershell
          ob-rust
          ob-mermaid
          markdown-mode
          markdown-mermaid
          markdown-toc
          grip-mode
          # Tools (tools.el)
          pdf-tools
          saveplace-pdf-view
          # MELPA's nov is fetched from a host whose certificate has expired.
          nongnuPackages.nov
          elfeed
          fanyi
          gt
          docker
          persistent-scratch
          rg
          pomidor
          olivetti
          atomic-chrome
          ztree
          file-info
          reveal-in-folder
          gptel
          gptel-magit
          agent-shell
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
              # For Centaur's modes (markdown-ts-mode, langs.el).
              tree-sitter-markdown
              tree-sitter-markdown-inline
              tree-sitter-ruby
              tree-sitter-elixir
              tree-sitter-heex
              tree-sitter-lua
              tree-sitter-scala
              tree-sitter-swift
              tree-sitter-php
              tree-sitter-java
              tree-sitter-proto
              tree-sitter-mermaid
              tree-sitter-scss
              tree-sitter-fish
            ]))
        ];
    };

    # The daemon as a systemd user service, the way Home Manager documents
    # it: it starts once the graphical session is up (so it has the Wayland
    # display), and its socket starts it again on demand after a stop. A
    # switch doesn't restart it; `systemctl --user restart emacs` does.
    services.emacs = {
      enable = true;
      package = emacs;
      startWithUserSession = "graphical";
      socketActivation.enable = true;
    };

    home.packages = [
      # ghostel's TERM is xterm-ghostty; programs in it need its terminfo.
      pkgs.ghostty.terminfo
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
        # The text types it opens by default (pcmanfm.nix).
        mimeType = [
          "text/plain"
          "text/markdown"
          "text/x-org"
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
      # The start page's art (lisp/dashboard.el).
      "emacs/splash.png".source = ./splash.png;
      "emacs/paths.el".text = ''
        ;;; paths.el -*- lexical-binding: t -*-
        (defvar my-tools-directory "${tools}/bin")
        (defvar my-keybindings-file "/etc/nixos/modules/programs/emacs/org/keybindings.org")
        (defvar my-org-directory "${orgDir}/")
        ;; Background opacity (appearance/_style.nix); text stays solid.
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
        mkdir -p "$orgDir/notes" "$orgDir/journal"
        for f in inbox tasks; do
          [ -f "$orgDir/$f.org" ] || install -m 0644 ${./org}/$f.org "$orgDir/$f.org"
        done
      fi
    '';
  };
}

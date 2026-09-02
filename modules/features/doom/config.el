;;; config.el -*- lexical-binding: t; -*-

;; User
(setq user-full-name "Pollux"
      user-mail-address "pollux@castor.local")

;; Fonts
(setq doom-font (font-spec :family "Maple Mono NF" :size 14 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Maple Mono NF" :size 14)
      doom-symbol-font (font-spec :family "Symbola"))

(setq display-line-numbers-type 'relative)

;; Theme from themes/ directory
(setq doom-theme 'doom-nano-dark)

(use-package! doom-nano-modeline
  :config
  (doom-nano-modeline-mode 1))

(setq-default x-stretch-cursor t)
(setq frame-resize-pixelwise t)

;; Projectile
(after! projectile
  (setq projectile-project-root-files
        '(".projectile" "flake.nix" "CMakeLists.txt" "compile_commands.json"
          "Cargo.toml" "build.zig" "mix.exs" "stack.yaml" "dune-project"
          "package.json" ".git"))
  (setq projectile-project-search-path '("~/projects" "~/src" "~/dev")
        projectile-auto-discover t
        projectile-enable-caching t))

;; Direnv
(after! direnv
  (setq direnv-always-show-summary nil)
  (direnv-mode 1))

;; Eglot / Clangd
(after! eglot
  (set-eglot-client! 'c++-mode '("clangd" "--background-index" "--clang-tidy" "--completion-style=detailed"))
  (set-eglot-client! 'c++-ts-mode '("clangd" "--background-index" "--clang-tidy" "--completion-style=detailed"))
  (set-eglot-client! 'c-mode '("clangd" "--background-index" "--clang-tidy"))
  (set-eglot-client! 'c-ts-mode '("clangd" "--background-index" "--clang-tidy"))
  (setq eglot-events-buffer-size 0
        eglot-autoshutdown t))

(setq-hook! '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook)
  c-basic-offset 4
  tab-width 4)

;; Terminal (Ghostel)
(after! ghostel
  (map! :leader
        (:prefix ("o" . "open")
         :desc "Ghostel popup" "t" #'+ghostel/toggle
         :desc "Ghostel full"  "T" #'+ghostel/open)))

;; Quickrun
(use-package! quickrun
  :commands (quickrun quickrun-region quickrun-with-arg)
  :config
  (map! :leader
        (:prefix ("r" . "quickrun")
         :desc "Quickrun buffer" "r" #'quickrun
         :desc "Quickrun region" "v" #'quickrun-region
         :desc "Quickrun with args" "a" #'quickrun-with-arg)))

;; ECA
(use-package! eca
  :commands (eca-mode)
  :config
  (map! :leader
        (:prefix ("a" . "ai")
         :desc "ECA prompt" "p" #'eca-chat-send-prompt
         :desc "ECA toggle" "t" #'eca-mode)))

;; Shell compatibility for Nushell
(setq shell-file-name (executable-find "bash"))
(setq-default explicit-shell-file-name "/run/current-system/sw/bin/nu")

;;; config.el -*- lexical-binding: t; -*-

;; =============================================================================
;; 1. User & Identity
;; =============================================================================
(setq user-full-name "Pollux"
      user-mail-address "pollux@castor.local")

;; =============================================================================
;; 2. Visuals, Fonts & Nano Theme / Modeline
;; =============================================================================
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 14)
      doom-symbol-font (font-spec :family "Symbola"))

(setq display-line-numbers-type 'relative)

;; Load doom-nano-theme & doom-nano-modeline
(use-package! doom-nano-themes
  :config
  (load-theme 'doom-nano-dark t))

(use-package! doom-nano-modeline
  :after doom-nano-themes
  :config
  (doom-nano-modeline-mode 1))

(setq-default x-stretch-cursor t)
(setq frame-resize-pixelwise t)

;; =============================================================================
;; 3. Projectile (Project Root Detection & .projectile)
;; =============================================================================
(after! projectile
  ;; Project root detection markers
  (setq projectile-project-root-files
        '(".projectile"           ; Explicit Projectile marker
          "flake.nix"             ; Nix Flake root
          "CMakeLists.txt"        ; C/C++ root
          "compile_commands.json" ; Clangd compilation database
          "Cargo.toml"            ; Rust root
          "build.zig"             ; Zig root
          "mix.exs"               ; Elixir root
          "stack.yaml"            ; Haskell root
          "dune-project"          ; OCaml root
          "package.json"          ; JS/TS root
          ".git"))                ; Git root

  ;; Search paths for your projects
  (setq projectile-project-search-path '("~/projects" "~/src" "~/dev"))

  ;; Auto-discover new projects when entering a folder
  (setq projectile-auto-discover t
        projectile-enable-caching t))

;; =============================================================================
;; 4. Direnv & Environment Management
;; =============================================================================
(after! direnv
  (setq direnv-always-show-summary nil)
  (direnv-mode 1))

;; =============================================================================
;; 5. Language Servers (Eglot / LSP) & C++ Setup
;; =============================================================================
(after! eglot
  ;; Configure clangd for C/C++ with background indexing & header inspection
  (set-eglot-client! 'c++-mode '("clangd" "--background-index" "--clang-tidy" "--completion-style=detailed"))
  (set-eglot-client! 'c++-ts-mode '("clangd" "--background-index" "--clang-tidy" "--completion-style=detailed"))
  (set-eglot-client! 'c-mode '("clangd" "--background-index" "--clang-tidy"))
  (set-eglot-client! 'c-ts-mode '("clangd" "--background-index" "--clang-tidy"))

  ;; Optimize eglot performance with event throttling
  (setq eglot-events-buffer-size 0
        eglot-autoshutdown t))

;; Format C++ with 4-space indent by default
(setq-hook! '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook)
  c-basic-offset 4
  tab-width 4)

;; =============================================================================
;; 6. Terminal (Ghostel)
;; =============================================================================
(after! ghostel
  (map! :leader
        (:prefix ("o" . "open")
         :desc "Ghostel popup" "t" #'+ghostel/toggle
         :desc "Ghostel full"  "T" #'+ghostel/open)))

;; =============================================================================
;; 7. Quickrun Configuration
;; =============================================================================
(use-package! quickrun
  :commands (quickrun quickrun-region quickrun-with-arg)
  :config
  (map! :leader
        (:prefix ("r" . "quickrun")
         :desc "Quickrun buffer" "r" #'quickrun
         :desc "Quickrun region" "v" #'quickrun-region
         :desc "Quickrun with args" "a" #'quickrun-with-arg)))

;; =============================================================================
;; 8. ECA (Editor Code Assistant)
;; =============================================================================
(use-package! eca
  :commands (eca-mode)
  :config
  (map! :leader
        (:prefix ("a" . "ai")
         :desc "ECA prompt" "p" #'eca-chat-send-prompt
         :desc "ECA toggle" "t" #'eca-mode)))

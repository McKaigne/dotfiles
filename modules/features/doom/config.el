
;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; Identity
(setq user-full-name "Pollux"
      user-mail-address "pollux@castor.local")

;;; UI: theme, fonts, dashboard
(setq doom-theme 'doom-nano-light)
(setq doom-font (font-spec :family "Maple Mono NF" :size 14))
(setq display-line-numbers-type 'relative)

;; Custom dashboard banner if present
(when (file-exists-p (concat doom-user-dir "carabao.svg"))
  (setq fancy-splash-image (concat doom-user-dir "carabao.svg")))

;; Configure doom-nano-modeline
(use-package! doom-nano-modeline
  :config
  (doom-nano-modeline-mode 1)
  (global-hide-mode-line-mode 1))

;;; Org
(setq org-directory "~/org/")

;;; Shells
(setq shell-file-name (executable-find "bash"))
(setq-default vterm-shell "/run/current-system/sw/bin/nu")
(setq-default explicit-shell-file-name "/run/current-system/sw/bin/nu")

;;; LSP: clangd on NixOS (matches both standard and tree-sitter C/C++ modes)
(after! eglot
  (add-to-list 'eglot-server-programs
               `((c++-mode c-mode c++-ts-mode c-ts-mode)
                 . ("clangd"
                    "--background-index"
                    "--clang-tidy"
                    "--completion-style=detailed"
                    ,(concat "--query-driver=" (or (getenv "CASTOR_CLANGXX") "/nix/store/**"))))))

;;; Projectile
(after! projectile
  (setq projectile-enable-caching t
        projectile-indexing-method 'hybrid)
  (dolist (marker '("Cargo.toml"
                    "pyproject.toml"
                    "CMakeLists.txt"
                    "compile_commands.json"
                    "setup.py"
                    "requirements.txt"
                    "Pipfile"
                    "build.zig"
                    "build.zig.zon"
                    "mix.exs"
                    "stack.yaml"
                    "package.yaml"
                    "cabal.project"
                    "dune-project"
                    "flake.nix"))
    (add-to-list 'projectile-project-root-files marker))

  (defun +projectile-root-with-glob (glob)
    "Return a root-detection function for use in `projectile-project-root-functions'."
    `(lambda (dir)
       (let ((root
              (locate-dominating-file
               dir
               (lambda (d)
                 (seq-some #'file-regular-p
                           (file-expand-wildcards (expand-file-name ,glob d)))))))
         (unless (and root (file-equal-p root (expand-file-name "~/")))
           root))))

  (dolist (glob '("*.opam" "*.rockspec"))
    (add-to-list 'projectile-project-root-functions
                 (+projectile-root-with-glob glob))))

;;; Navigation
(setq scroll-margin 99999
      scroll-conservatively 0
      maximum-scroll-margin 0.5)

(map! :leader
      (:prefix ("j" . "jump")
       :desc "Jump to char" "j" #'avy-goto-char
       :desc "Jump to word" "w" #'avy-goto-word-1
       :desc "Jump to line" "l" #'avy-goto-line))

;;; Packages
(use-package! quickrun)
(map! :leader
      (:prefix ("r" . "Run")
       :desc "Quickrun" "r" #'quickrun
       :desc "Quickrun Shell" "s" #'quickrun-shell))

(add-to-list 'load-path "~/.config/emacs-lisp/ghostel/lisp")
(require 'ghostel nil t)

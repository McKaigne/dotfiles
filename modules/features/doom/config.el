
;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; Identity
(setq user-full-name "Pollux"
      user-mail-address "pollux@castor.local")

;;; UI: theme, fonts, dashboard
(setq doom-theme 'noctalia)
(setq doom-font (font-spec :family "Maple Mono NF" :size 14))
(setq display-line-numbers-type 'relative)

;; Cursor Shapes: Normal = Block, Insert = Vertical Bar / Line
(setq evil-normal-state-cursor 'box
      evil-insert-state-cursor 'bar
      evil-visual-state-cursor 'hollow
      evil-replace-state-cursor 'hbar)

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

;;; Shells: POSIX for internal machinery, Nushell for interactive terminals & Ghostel
(setq shell-file-name (executable-find "bash"))
(setq explicit-shell-file-name "/run/current-system/sw/bin/nu")
(setq-default explicit-shell-file-name "/run/current-system/sw/bin/nu")
(setq-default vterm-shell "/run/current-system/sw/bin/nu")

;; Configure Ghostel to use Nushell
(after! ghostel
  (setq ghostel-default-shell "/run/current-system/sw/bin/nu")
  (map! :leader
        (:prefix ("o" . "open")
         :desc "Ghostel popup" "t" #'+ghostel/toggle
         :desc "Ghostel full"  "T" #'+ghostel/open)))

;;; Projectile
(after! projectile
  (setq projectile-enable-caching t
        projectile-indexing-method 'hybrid)
  (dolist (marker '("Cargo.toml" "pyproject.toml" "CMakeLists.txt" "compile_commands.json" "build.zig" "flake.nix"))
    (add-to-list 'projectile-project-root-files marker)))

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

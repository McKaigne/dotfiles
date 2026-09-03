
;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run
;; 'doom sync' after modifying this file!


;;; Identity
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")


;;; UI: theme, fonts, dashboard

;; Load NANO theme (options: 'doom-nano-light or 'doom-nano-dark)
(setq doom-theme 'noctalia)

(setq doom-font (font-spec :family "Maple Mono NF" :size 14))

(setq display-line-numbers-type 'relative)

;; Replace default Doom dashboard logo with custom banner.
(setq fancy-splash-image (concat doom-user-dir "carabao.svg"))

;; Configure doom-nano-modeline
(use-package! doom-nano-modeline
  :config
  (doom-nano-modeline-mode 1)
  (global-hide-mode-line-mode 1))

;; ;; Transparency
;; (set-frame-parameter (selected-frame) 'alpha '(90 . 90))
;; (add-to-list 'default-frame-alist '(alpha . (90 . 90)))
;; (add-to-list 'default-frame-alist '(alpha-background . 90))
;; (set-frame-parameter (selected-frame) 'alpha-background 90)


;;; Org
;; Must be set before org loads!
(setq org-directory "~/org/")


;;; Shells: bash for internal machinery, fish for interactive terminals ---------

;; Internal Emacs machinery (diff-hl, compile, TRAMP) uses bash
(setq shell-file-name (executable-find "bash"))

;; Interactive terminal emulators (vterm, if you use it) use fish
(setq-default vterm-shell "/usr/bin/fish")
(setq-default explicit-shell-file-name "/usr/bin/fish")

;; (use-package! ghostel-compile :hook (after-init . ghostel-compile-global-mode))


;; Projectile
;; Projectile's actual current default `projectile-project-root-files' is
;; small: GTAGS, TAGS, configure.ac, configure.in, cscope.out. (A commonly
;; repeated 2020-era default list circulating online -- CMakeLists.txt,
;; Cargo.toml, setup.py, etc. -- no longer reflects the real source; verified
;; directly against the current projectile.el on GitHub.) Only `Makefile' is
;; separately covered, via `projectile-project-root-files-top-down-recurring'.
;; So every language manifest below is added explicitly, per active :lang
;; module in init.el -- none of it is redundant with the real defaults.
(after! projectile
  (setq projectile-enable-caching t
        projectile-indexing-method 'hybrid)
  (dolist (marker '("Cargo.toml"       ; Rust
                    "pyproject.toml"  ; Python (modern, PEP 517/518)
                    "CMakeLists.txt"  ; C/C++
                    "setup.py"        ; Python (legacy)
                    "requirements.txt" ; Python
                    "Pipfile"         ; Python (pipenv)
                    "build.zig"       ; Zig build script
                    "build.zig.zon"   ; Zig package manifest
                    "mix.exs"         ; Elixir
                    "stack.yaml"      ; Haskell (Stack)
                    "package.yaml"    ; Haskell (hpack)
                    "cabal.project"   ; Haskell (Cabal, multi-package)
                    "dune-project"))  ; OCaml (Dune)
    (add-to-list 'projectile-project-root-files marker))
  ;; `projectile-project-root-files' only matches exact filenames, so
  ;; wildcard manifests (OCaml's "*.opam", Lua's "*.rockspec") need a
  ;; small helper function instead of a plain string entry.
  (defun +projectile-root-with-glob (glob)
    "Return a root-detection function that searches upward for a
regular file matching GLOB, for use in
`projectile-project-root-functions'. Stops at $HOME so a stray
matching file or directory there (e.g. opam's own ~/.opam) can
never be mistaken for a project root."
    (lambda (dir)
      (let ((root
             (locate-dominating-file
              dir
              (lambda (d)
                (seq-some #'file-regular-p
                          (file-expand-wildcards (expand-file-name glob d)))))))
        (unless (and root (file-equal-p root (expand-file-name "~/")))
          root))))
  (dolist (glob '("*.opam"      ; OCaml (opam package, no dune-project file)
                  "*.rockspec")) ; Lua (LuaRocks)
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
(require 'ghostel)

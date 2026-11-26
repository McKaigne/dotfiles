;;; dev.el -*- lexical-binding: t -*-

(setq treesit-auto-install-grammar 'never
      treesit-font-lock-level 4)
(setopt treesit-enabled-modes
        '(c-ts-mode c++-ts-mode c-or-c++-ts-mode rust-ts-mode python-ts-mode
          go-ts-mode go-mod-ts-mode bash-ts-mode yaml-ts-mode
          toml-ts-mode json-ts-mode cmake-ts-mode))

(dolist (entry '(("\\.html?\\'" . html-ts-mode)
                 ("\\.rs\\'" . rust-ts-mode)
                 ("\\.go\\'" . go-ts-mode)
                 ("/go\\.mod\\'" . go-mod-ts-mode)
                 ("\\.ya?ml\\'" . yaml-ts-mode)
                 ("\\.toml\\'" . toml-ts-mode)
                 ("\\.json\\'" . json-ts-mode)
                 ("\\(?:CMakeLists\\.txt\\|\\.cmake\\)\\'" . cmake-ts-mode)))
  (add-to-list 'auto-mode-alist entry))

(setq find-sibling-rules
      '(("\\([^/]+\\)\\.\\(?:c\\|cc\\|cpp\\|cxx\\)\\'" "\\1.\\(?:h\\|hh\\|hpp\\|hxx\\)\\'")
        ("\\([^/]+\\)\\.\\(?:h\\|hh\\|hpp\\|hxx\\)\\'" "\\1.\\(?:c\\|cc\\|cpp\\|cxx\\)\\'")))

(use-package nix-ts-mode
  :mode "\\.nix\\'")

(use-package templ-ts-mode
  :mode "\\.templ\\'")

(use-package fish-mode
  :mode ("\\.fish\\'" "/fish_funced\\..*\\'"))

(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-italic-underscore t)
  (markdown-asymmetric-header t)
  (markdown-make-gfm-checkboxes-buttons t)
  (markdown-gfm-uppercase-checkbox t)
  (markdown-command '("cmark-gfm" "--unsafe" "--extension" "table"
                      "--extension" "strikethrough" "--extension" "autolink"
                      "--extension" "tasklist")))

(use-package eglot
  :hook ((c-ts-mode c++-ts-mode c-or-c++-ts-mode rust-ts-mode python-ts-mode
          go-ts-mode go-mod-ts-mode html-ts-mode templ-ts-mode nix-ts-mode
          cmake-ts-mode)
         . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-config '(:size 0 :format short))
  (eglot-send-changes-idle-time 0.5)
  (eglot-connect-timeout 30)
  (eglot-extend-to-xref t)
  :config
  (dolist (entry '(((c-ts-mode c++-ts-mode c-or-c++-ts-mode)
                    . ("clangd" "--background-index" "--clang-tidy"))
                   (nix-ts-mode . ("nixd"))
                   (python-ts-mode . ("basedpyright-langserver" "--stdio"))
                   (html-ts-mode . ("htmx-lsp"))
                   (templ-ts-mode . ("templ" "lsp"))
                   (cmake-ts-mode . ("neocmakelsp" "stdio"))))
    (add-to-list 'eglot-server-programs entry)))

(use-package eldoc-box
  :commands eldoc-box-help-at-point)

(use-package flymake
  :hook (emacs-lisp-mode . flymake-mode)
  :custom
  (flymake-fringe-indicator-position 'right-fringe))

(use-package flyover
  :hook (flymake-mode . flyover-mode)
  :custom
  (flyover-checkers '(flymake))
  (flyover-base-height 1.0)
  (flyover-levels '(error warning info))
  (flyover-display-mode 'always)
  (flyover-line-position-offset 1)
  (flyover-show-at-eol nil)
  (flyover-show-virtual-line nil)
  (flyover-border-style 'none)
  (flyover-show-icon t)
  (flyover-use-theme-colors t)
  (flyover-hide-checker-name nil)
  (flyover-show-error-id t)
  (flyover-wrap-messages t)
  (flyover-max-line-length 80)
  (flyover-hide-during-completion t))

(use-package apheleia
  :demand t
  :config
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff
        (alist-get 'go-ts-mode apheleia-mode-alist) 'gofumpt
        (alist-get 'nix-ts-mode apheleia-mode-alist) 'nixfmt)
  (apheleia-global-mode 1))

(use-package treesit-fold
  :commands (treesit-fold-toggle treesit-fold-open-all treesit-fold-close-all))

(defun nixmacs-treesit-fold-maybe ()
  "Turn on folding when this buffer is parsed by tree-sitter."
  (when (and (treesit-available-p) (treesit-parser-list))
    (treesit-fold-mode 1)))

(add-hook 'prog-mode-hook #'nixmacs-treesit-fold-maybe 90)
(add-hook 'conf-mode-hook #'nixmacs-treesit-fold-maybe 90)

(use-package jinx
  :hook ((text-mode prog-mode conf-mode) . jinx-mode)
  :custom
  (jinx-languages "en_US"))

(use-package magit
  :commands (magit-status magit-dispatch magit-file-dispatch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-diff-refine-hunk t))

(defun nixmacs-diff-hl-bitmap (_type _pos)
  "Draw every change as the same solid bar."
  'nixmacs-diff-hl-bar)

(defun nixmacs-diff-hl-colors (&rest _)
  "Color the git gutter bars from the theme, on the fringe's background."
  (pcase-dolist (`(,face . ,source) '((diff-hl-insert . success)
                                      (diff-hl-change . warning)
                                      (diff-hl-delete . error)))
    (set-face-attribute face nil
                        :foreground (face-foreground source nil t)
                        :background 'unspecified
                        :inherit nil)))

(use-package diff-hl
  :demand t
  :hook ((magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (dired-mode . diff-hl-dired-mode))
  :custom
  (diff-hl-fringe-bmp-function #'nixmacs-diff-hl-bitmap)
  (diff-hl-draw-borders nil)
  :config
  (define-fringe-bitmap 'nixmacs-diff-hl-bar [7] nil 3 '(center repeated))
  (nixmacs-diff-hl-colors)
  (add-hook 'enable-theme-functions #'nixmacs-diff-hl-colors 90)
  (require 'diff-hl-flydiff)
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1))

(use-package vundo
  :commands vundo
  :custom
  (vundo-glyph-alist vundo-unicode-symbols))

(use-package envrc
  :demand t
  :config
  (envrc-global-mode 1))

(defun nixmacs-project-environment-setup ()
  "Create and allow a direnv file that loads the project's flake shell."
  (interactive)
  (let* ((project (or (project-current) (user-error "Not in a project")))
         (default-directory (project-root project))
         (file (expand-file-name ".envrc")))
    (unless (file-exists-p "flake.nix")
      (user-error "This project has no flake.nix"))
    (if (file-exists-p file)
        (find-file file)
      (with-temp-file file (insert "use flake\n")))
    (envrc-allow)
    (envrc-reload)))

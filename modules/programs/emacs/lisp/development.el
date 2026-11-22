;;; development.el -*- lexical-binding: t -*-

(require 'envrc)
(require 'eglot)

;; Tree-sitter: grammars come from Nix (treesit-grammars.with-all-grammars),
;; so prefer the -ts- mode wherever its grammar is present.
(dolist (entry '((c-mode c-ts-mode c) (c++-mode c++-ts-mode cpp)
                 (c-or-c++-mode c-or-c++-ts-mode cpp)
                 (python-mode python-ts-mode python) (sh-mode bash-ts-mode bash)
                 (js-mode js-ts-mode javascript) (javascript-mode js-ts-mode javascript)
                 (js-json-mode json-ts-mode json) (css-mode css-ts-mode css)
                 (conf-toml-mode toml-ts-mode toml)
                 (mhtml-mode html-ts-mode html) (html-mode html-ts-mode html)))
  (when (treesit-language-available-p (nth 2 entry))
    (add-to-list 'major-mode-remap-alist (cons (nth 0 entry) (nth 1 entry)))))
(dolist (entry '(("\\.ya?ml\\'" . yaml-ts-mode) ("\\.ts\\'" . typescript-ts-mode)
                 ("\\.tsx\\'" . tsx-ts-mode) ("\\.rs\\'" . rust-ts-mode)
                 ("\\.go\\'" . go-ts-mode) ("/go\\.mod\\'" . go-mod-ts-mode)
                 ("CMakeLists\\.txt\\'" . cmake-ts-mode) ("Dockerfile\\'" . dockerfile-ts-mode)))
  (add-to-list 'auto-mode-alist entry))
(setq treesit-font-lock-level 4)

(use-package nix-mode :mode "\\.nix\\'")
;; Language modes from packages (autoloads are off in this config, so each
;; mode is declared with the files it handles). templ is edited in Helix:
;; templ-ts-mode does not work with Emacs 31's Go mode.
(use-package haskell-ts-mode :mode "\\.hs\\'")
(use-package julia-ts-mode :mode "\\.jl\\'")
(use-package kotlin-ts-mode :mode "\\.kts?\\'")
(use-package dart-mode :mode "\\.dart\\'")
(use-package typst-ts-mode :mode "\\.typ\\'")
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode) ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-command '("cmark-gfm" "--unsafe" "--extension" "table"
                       "--extension" "strikethrough" "--extension" "autolink"
                       "--extension" "tasklist")))

(defvar-local lysec-markdown-preview-source nil)

(defun lysec-markdown-render-code (dom)
  "Render DOM as code with terminal-visible styling."
  (shr-fontize-dom dom 'org-code))

(defun lysec-markdown-render-code-block (dom)
  "Render DOM as a code block, preserving whitespace."
  (let ((start (point)))
    (shr-tag-pre dom)
    (shr-add-font start (point) 'org-block)))

(defun lysec-markdown-preview ()
  "Render Markdown in a reading pane, or refresh its existing preview."
  (interactive)
  (require 'eww)
  (let* ((source (or lysec-markdown-preview-source (current-buffer)))
         (html (generate-new-buffer " *Markdown HTML*"))
         preview)
    (unwind-protect
        (with-current-buffer source
          (unless (derived-mode-p 'markdown-mode)
            (user-error "Open a Markdown buffer first"))
          (let* ((name (buffer-name))
                 (directory default-directory)
                 (url (url-encode-url (concat "file://" (or buffer-file-name directory)))))
            (save-excursion
              (save-restriction
                (widen)
                (let ((mark-active nil))
                  (markdown-standalone (buffer-name html) name))))
            (setq preview (get-buffer-create (format "*Markdown: %s*" name)))
            (with-current-buffer preview
              (eww-mode)
              (setq-local lysec-markdown-preview-source source
                          default-directory directory
                          shr-use-fonts nil
                          shr-use-colors nil
                          shr-inhibit-images t
                          shr-table-horizontal-line ?─
                          shr-table-vertical-line ?│
                          shr-table-corner ?┼
                          shr-external-rendering-functions
                          '((code . lysec-markdown-render-code)
                            (pre . lysec-markdown-render-code-block))
                          eww-data (list :url url))
              (dotimes (index 6)
                (face-remap-add-relative
                 (intern (format "shr-h%d" (1+ index)))
                 :inherit (intern (format "org-level-%d" (1+ index)))
                 :height 1.0 :weight 'bold :slant 'normal))
              (let ((map (copy-keymap eww-mode-map)))
                (define-key map (kbd "g") #'lysec-markdown-preview)
                (use-local-map map)))
            (pop-to-buffer preview
                           '((display-buffer-reuse-window display-buffer-in-side-window)
                             (side . right) (slot . 0) (window-width . 0.5)))
            (with-current-buffer html
              (goto-char (point-min))
              (eww-display-html 'utf-8 url nil nil preview))
            (with-current-buffer preview (set-buffer-modified-p nil))))
      (kill-buffer html))
    (set-buffer preview)))

(setq c-basic-offset 4
      eglot-autoshutdown t
      eglot-events-buffer-config '(:size 0 :format full)
      eglot-connect-timeout 30)
(add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
(add-to-list 'eglot-server-programs
             '((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio")))
(add-to-list 'eglot-server-programs '((toml-ts-mode conf-toml-mode) . ("taplo" "lsp" "stdio")))
(add-to-list 'eglot-server-programs
             '((js-ts-mode typescript-ts-mode tsx-ts-mode) . ("vtsls" "--stdio")))
(add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist")))
(add-to-list 'eglot-server-programs '(kotlin-ts-mode . ("kotlin-language-server")))
(add-to-list 'eglot-server-programs
             '(haskell-ts-mode . ("haskell-language-server-wrapper" "--lsp")))
;; Julia: LanguageServer.jl from the default Julia environment, started the
;; same way Helix does (installed once with Pkg.add, see languages.nix).
(add-to-list 'eglot-server-programs
             '(julia-ts-mode . ("julia" "--startup-file=no" "--history-file=no" "--quiet"
                                "-e" "using LanguageServer; runserver()")))
(add-to-list 'eglot-server-programs
             '((c-mode c++-mode c-ts-mode c++-ts-mode)
               . ("clangd" "--background-index" "--clang-tidy")))

(defun lysec-start-language-server ()
  "Load the project environment, then connect the language server."
  (when (and buffer-file-name
             (not (file-remote-p buffer-file-name))
             (derived-mode-p 'nix-mode 'c-mode 'c++-mode 'c-ts-mode 'c++-ts-mode
                             'python-ts-mode 'python-mode 'bash-ts-mode 'sh-mode
                             'json-ts-mode 'yaml-ts-mode 'css-ts-mode 'html-mode
                             'html-ts-mode 'toml-ts-mode 'markdown-mode
                             'rust-ts-mode 'go-ts-mode 'go-mod-ts-mode
                             'js-ts-mode 'typescript-ts-mode 'tsx-ts-mode
                             'haskell-ts-mode 'julia-ts-mode 'kotlin-ts-mode
                             'dart-mode 'typst-ts-mode))
    (envrc-mode 1)
    (setq-local exec-path (append exec-path (list lysec-tools-directory)))
    (eglot-ensure)))

(add-hook 'find-file-hook #'lysec-start-language-server t)
(add-hook 'after-revert-hook #'lysec-start-language-server)
(add-hook 'eglot-managed-mode-hook
          (lambda () (setq-local completion-category-defaults nil)))

(use-package apheleia
  :demand t
  :config
  (setf (alist-get 'nixfmt apheleia-formatters) '("nixfmt"))
  (setf (alist-get 'typstyle apheleia-formatters) '("typstyle"))
  (setf (alist-get 'prettier-markdown apheleia-formatters)
        '("prettier" "--parser" "markdown" "--stdin-filepath" filepath))
  (dolist (entry '((nix-mode . nixfmt)
                   (c-mode . clang-format)
                   (c++-mode . clang-format)
                   (c-ts-mode . clang-format)
                   (c++-ts-mode . clang-format)
                   (markdown-mode . prettier-markdown)
                   (sh-mode . shfmt)
                   (bash-ts-mode . shfmt)
                   (python-mode . ruff)
                   (python-ts-mode . ruff)
                   (go-ts-mode . gofumpt)
                   (rust-ts-mode . rustfmt)
                   (haskell-ts-mode . ormolu)
                   (dart-mode . dart-format)
                   (typst-ts-mode . typstyle)))
    (setf (alist-get (car entry) apheleia-mode-alist) (cdr entry)))
  (setq apheleia-inhibit-functions
        (cons (lambda ()
                (or (derived-mode-p 'json-mode 'js-json-mode 'json-ts-mode)
                    (and buffer-file-name
                         (string-match-p "\\.json\\'" buffer-file-name))))
              apheleia-inhibit-functions))
  (apheleia-global-mode 1))

(defun lysec-project-environment-setup ()
  "Create and allow a direnv file using the project's default flake shell."
  (interactive)
  (let* ((project (project-current t))
         (default-directory (project-root project))
         (file (expand-file-name ".envrc")))
    (unless (file-exists-p "flake.nix")
      (user-error "This project has no flake.nix"))
    (if (file-exists-p file)
        (find-file file)
      (with-temp-file file (insert "use flake\n")))
    (envrc-allow)
    (envrc-reload)))

;; Build and run: ANSI colours, follow output to the first error, and each
;; project remembers its own last compile command.
(require 'ansi-color)
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)
(setq compilation-scroll-output 'first-error
      compilation-ask-about-save nil)

(defvar lysec-compile-history (make-hash-table :test #'equal)
  "Last compile command per project root.")
(define-advice project-compile (:around (fn &rest args) remember)
  "Offer this project's previous command, and remember the new one."
  (let* ((root (project-root (project-current t)))
         (compile-command (gethash root lysec-compile-history compile-command)))
    (apply fn args)
    (puthash root compile-command lysec-compile-history)))

;; A real terminal in the bottom panel (vterm is prebuilt by Nix).
(use-package vterm
  :commands vterm
  :custom (vterm-max-scrollback 10000))
(use-package vterm-toggle
  :commands (vterm-toggle vterm-toggle-cd)
  :custom (vterm-toggle-scope 'project))
(add-to-list 'display-buffer-alist
             '((major-mode . vterm-mode)
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom) (slot . 1) (window-height . 0.3)))

;; Snippets: type a snippet's key and TAB, or pick one with SPC c s. eglot
;; uses yasnippet too, so language-server completions expand into fields.
(use-package yasnippet
  :demand t
  :config
  (require 'yasnippet-snippets)
  (yas-global-mode 1))

;; Faster language servers: eglot-booster puts emacs-lsp-booster between
;; eglot and the server, so JSON parsing happens off the main thread.
(use-package eglot-booster
  :after eglot
  :config (eglot-booster-mode 1))

;; Select whole functions, classes and arguments as meow things.
(use-package meow-tree-sitter
  :after meow
  :config (meow-tree-sitter-register-defaults))

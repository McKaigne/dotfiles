;;; development.el -*- lexical-binding: t -*-

(require 'envrc)
(require 'eglot)

;; Tree-sitter: grammars come from Nix (default.nix), so prefer the -ts-
;; mode wherever its grammar is present, as Centaur does (except Rust, which
;; uses rust-mode on top of tree-sitter). Listed rather than set with
;; `treesit-enabled-modes', which at startup drops these remaps.
(dolist (entry '((c-mode c-ts-mode c) (c++-mode c++-ts-mode cpp)
                 (c-or-c++-mode c-or-c++-ts-mode cpp)
                 (python-mode python-ts-mode python) (sh-mode bash-ts-mode bash)
                 (js-mode js-ts-mode javascript) (javascript-mode js-ts-mode javascript)
                 (js-json-mode json-ts-mode json) (css-mode css-ts-mode css)
                 (conf-toml-mode toml-ts-mode toml)
                 (mhtml-mode html-ts-mode html) (html-mode html-ts-mode html)
                 ;; Centaur's other languages (langs.el).
                 (elixir-mode elixir-ts-mode elixir) (lua-mode lua-ts-mode lua)
                 (java-mode java-ts-mode java)))
  (when (treesit-language-available-p (nth 2 entry))
    (add-to-list 'major-mode-remap-alist (cons (nth 0 entry) (nth 1 entry)))))
(dolist (entry '(("\\.ya?ml\\'" . yaml-ts-mode) ("\\.ts\\'" . typescript-ts-mode)
                 ("\\.tsx\\'" . tsx-ts-mode)
                 ("\\.go\\'" . go-ts-mode) ("/go\\.mod\\'" . go-mod-ts-mode)
                 ("CMakeLists\\.txt\\'" . cmake-ts-mode) ("Dockerfile\\'" . dockerfile-ts-mode)))
  (add-to-list 'auto-mode-alist entry))
(setq treesit-font-lock-level 4)

(use-package nix-mode :mode "\\.nix\\'")
;; Language modes from packages. templ has none: templ-ts-mode does not
;; work with Emacs 31's Go mode.
(use-package haskell-ts-mode :mode "\\.hs\\'")
(use-package julia-ts-mode :mode "\\.jl\\'")
(use-package kotlin-ts-mode :mode "\\.kts?\\'")
(use-package dart-mode :mode "\\.dart\\'")
(use-package typst-ts-mode :mode "\\.typ\\'")
(setq c-basic-offset 4
      eglot-autoshutdown t
      eglot-events-buffer-config '(:size 0 :format short)
      eglot-send-changes-idle-time 0.5
      eglot-connect-timeout 30)
(add-to-list 'eglot-server-programs '(nix-mode . ("nixd")))
(add-to-list 'eglot-server-programs
             '((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio")))
(add-to-list 'eglot-server-programs '((toml-ts-mode conf-toml-mode) . ("taplo" "lsp" "stdio")))
(add-to-list 'eglot-server-programs
             '((js-ts-mode typescript-ts-mode tsx-ts-mode) . ("vtsls" "--stdio")))
(add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist")))
(add-to-list 'eglot-server-programs '(web-mode . ("vscode-html-language-server" "--stdio")))
(add-to-list 'eglot-server-programs '(kotlin-ts-mode . ("kotlin-language-server")))
(add-to-list 'eglot-server-programs
             '(haskell-ts-mode . ("haskell-language-server-wrapper" "--lsp")))
;; Julia: LanguageServer.jl from the default Julia environment (installed
;; once with Pkg.add, see languages.nix).
(add-to-list 'eglot-server-programs
             '(julia-ts-mode . ("julia" "--startup-file=no" "--history-file=no" "--quiet"
                                "-e" "using LanguageServer; runserver()")))
(add-to-list 'eglot-server-programs
             '((c-mode c++-mode c-ts-mode c++-ts-mode)
               . ("clangd" "--background-index" "--clang-tidy")))

(defun my-start-language-server ()
  "Load the project environment, then connect the language server."
  (when (and buffer-file-name
             (not (file-remote-p buffer-file-name))
             (derived-mode-p 'nix-mode 'c-mode 'c++-mode 'c-ts-mode 'c++-ts-mode
                             'python-ts-mode 'python-mode 'bash-ts-mode 'sh-mode
                             'json-ts-mode 'yaml-ts-mode 'css-ts-mode 'html-mode
                             'html-ts-mode 'toml-ts-mode 'markdown-mode 'markdown-ts-mode
                             'rust-ts-mode 'rust-mode 'go-ts-mode 'go-mod-ts-mode
                             'js-ts-mode 'typescript-ts-mode 'tsx-ts-mode
                             'haskell-ts-mode 'julia-ts-mode 'kotlin-ts-mode
                             'dart-mode 'typst-ts-mode 'web-mode 'fish-mode
                             'ruby-ts-mode 'elixir-ts-mode 'lua-mode 'php-mode))
    (envrc-mode 1)
    (setq-local exec-path (append exec-path (list my-tools-directory)))
    (eglot-ensure)))

(add-hook 'find-file-hook #'my-start-language-server t)
(add-hook 'after-revert-hook #'my-start-language-server)
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
                   (rust-mode . rustfmt)
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

(defun my-project-environment-setup ()
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

(defvar my-compile-history (make-hash-table :test #'equal)
  "Last compile command per project root.")
(define-advice project-compile (:around (fn &rest args) remember)
  "Offer this project's previous command, and remember the new one."
  (let* ((root (project-root (project-current t)))
         (compile-command (gethash root my-compile-history compile-command)))
    (apply fn args)
    (puthash root compile-command my-compile-history)))

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

;; Centaur Emacs's check, LSP, debugger and programming modules
;; (lisp/init-check.el, init-lsp.el, init-dap.el, init-prog.el). Language
;; servers still start through `my-start-language-server' above, which
;; loads each project's Nix environment first.

(use-package flymake
  :functions my/elisp-flymake-byte-compile
  :bind ("C-c f" . flymake-show-buffer-diagnostics)
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-no-changes-timeout 0.15)
  (flymake-fringe-indicator-position 'right-fringe)
  (flymake-margin-indicator-position 'right-margin)
  :config
  (defun my/elisp-flymake-byte-compile (fn &rest args)
    "Advice function to make Flymake inherit `load-path' and packages."
    (let ((elisp-flymake-byte-compile-load-path
           (append elisp-flymake-byte-compile-load-path load-path)))
      (apply fn args)))
  (advice-add 'elisp-flymake-byte-compile :around #'my/elisp-flymake-byte-compile))

;; Display Flymake errors with overlays
(use-package flyover
  :custom
  (flyover-checkers '(flymake))
  (flyover-background-lightness (if (centaur-dark-theme-p) 35 75))
  (flyover-icon-background-tint-percent 50)
  :hook (flymake-mode . flyover-mode))

;; Jump to any symbol in the workspace
(use-package consult-eglot
  :after eglot
  :bind (:map eglot-mode-map
         ("C-M-." . consult-eglot-symbols)))

;; Language servers in Org source blocks (C-c ' edits them)
(cl-defmacro lsp-org-babel-enable (lang)
  "Support LANG in org source code block."
  (cl-check-type lang string)
  (let* ((edit-pre (intern (format "org-babel-edit-prep:%s" lang)))
         (intern-pre (intern (format "lsp--%s" (symbol-name edit-pre)))))
    `(progn
       (defun ,intern-pre (info)
         (setq buffer-file-name (or (alist-get :file (caddr info))
                                    "org-src-babel.tmp"))
         (when (fboundp 'eglot-ensure)
           (eglot-ensure)))
       (put ',intern-pre 'function-documentation
            (format "Enable LSP in the buffer of org source block (%s)." (upcase ,lang)))
       (if (fboundp ',edit-pre)
           (advice-add ',edit-pre :after ',intern-pre)
         (progn
           (defun ,edit-pre (info)
             (,intern-pre info))
           (put ',edit-pre 'function-documentation
                (format "Prepare local buffer environment for org source block (%s)."
                        (upcase ,lang))))))))

(defconst org-babel-lang-list
  '("go" "python" "ipython" "ruby" "js" "css" "sass" "c" "rust" "java" "cpp" "c++" "shell")
  "The supported programming languages for interactive Babel.")
(dolist (lang org-babel-lang-list)
  (eval `(lsp-org-babel-enable ,lang)))

;; Debug Adapter Protocol: F5 starts, M-F5 (or SPC d) is the debug menu.
(use-package dape
  :bind (("<f5>" . dape)
         ("M-<f5>" . my-dape-menu))
  :custom (dape-buffer-window-arrangement 'right)
  :config
  ;; Save buffers on startup, useful for interpreted languages
  (add-hook 'dape-start-hook
            (defun dape--save-on-start ()
              (save-some-buffers t t))))
(my-define-menu my-dape-menu "Debug"
  :pre (require 'dape)
  ("n" #'dape-next "next")
  ("s" #'dape-step-in "step in")
  ("o" #'dape-step-out "step out")
  ("c" #'dape-continue "continue")
  ("p" #'dape-pause "pause")
  ("k" #'dape-kill "kill")
  ("r" #'dape-restart "restart")
  ("D" #'dape-disconnect-quit "disconnect")
  ("m" #'dape-memory "memory")
  ("t" #'dape-select-thread "thread")
  ("w" #'dape-watch-dwim "watch")
  ("S" #'dape-select-stack "stack")
  ("i" #'dape-info "info")
  ("R" #'dape-repl "repl")
  ("b" #'dape-breakpoint-toggle "toggle breakpoint")
  ("l" #'dape-breakpoint-log "log breakpoint")
  ("e" #'dape-breakpoint-expression "expression breakpoint")
  ("B" #'dape-breakpoint-remove-all "clear breakpoints")
  ("d" #'dape "dape")
  ("Q" #'dape-quit "quit" :exit t))

;; Prettify symbols (lambda → λ, -> → →, ...) in code.
(use-package prog-mode
  :ensure nil
  :hook (prog-mode . prettify-symbols-mode)
  :init
  (setq-default prettify-symbols-alist
                '(("lambda" . ?λ)
                  ("<-"     . ?←)
                  ("->"     . ?→)
                  ("->>"    . ?↠)
                  ("=>"     . ?⇒)
                  ("map"    . ?↦)
                  ("/="     . ?≠)
                  ("!="     . ?≠)
                  ("=="     . ?≡)
                  ("<="     . ?≤)
                  (">="     . ?≥)
                  ("=<<"    . (?= (Br . Bl) ?≪))
                  (">>="    . (?≫ (Br . Bl) ?=))
                  ("<=<"    . ?↢)
                  (">=>"    . ?↣)
                  ("&&"     . ?∧)
                  ("||"     . ?∨)
                  ("not"    . ?¬)))
  (setq prettify-symbols-unprettify-at-point 'right-edge))

;; Documentation for the symbol at point in a floating box (C-h .)
(use-package eldoc-mouse
  :bind (:map emacs-lisp-mode-map
         ("C-h ." . eldoc-mouse-pop-doc-at-cursor)
         :map eglot-mode-map
         ("C-h ." . eldoc-mouse-pop-doc-at-cursor))
  :hook (eglot-managed-mode . eldoc-mouse-mode))

;; Cross-referencing commands
(use-package xref
  :bind (("M-g ." . xref-find-definitions)
         ("M-g ," . xref-go-back))
  :custom
  (xref-search-program (if (executable-find "rg") 'ripgrep 'grep))
  (xref-show-definitions-function #'xref-show-definitions-completing-read)
  (xref-show-xrefs-function #'xref-show-definitions-completing-read))

(use-package editorconfig
  :hook (after-init . editorconfig-mode))

;; Run any code
(use-package quickrun
  :bind (("C-<f5>" . quickrun)
         ("C-c x"  . quickrun)))

;;; langs.el -*- lexical-binding: t -*-

;; Centaur Emacs's language modules (lisp/init-elisp.el, init-c.el,
;; init-go.el, init-rust.el, init-python.el, init-ruby.el, init-elixir.el,
;; init-web.el) and the extra major modes from init-prog.el. Toolchains and
;; language servers come from Nix (development/languages.nix).

;; Emacs lisp mode
(use-package elisp-mode
  :ensure nil
  :defines elisp-scope-unsafe-macros
  :config
  ;; Syntax highlighting of known Elisp symbols
  (if (boundp 'elisp-fontify-semantically)
      ;; Built into Emacs 31+
      (progn
        (setq elisp-fontify-semantically t)
        (with-eval-after-load 'elisp-scope
          (add-to-list 'elisp-scope-unsafe-macros 'defhydra)))
    (use-package highlight-defined
      :hook (emacs-lisp-mode inferior-emacs-lisp-mode)))

  (with-no-warnings
    ;; Align indent keywords
    ;; @see https://emacs.stackexchange.com/questions/10230/how-to-indent-keywords-aligned
    (defun my/lisp-indent-function (indent-point state)
      "This function is the normal value of the variable `lisp-indent-function'.
The function `calculate-lisp-indent' calls this to determine
if the arguments of a Lisp function call should be indented specially.

INDENT-POINT is the position at which the line being indented begins.
Point is located at the point to indent under (for default indentation);
STATE is the `parse-partial-sexp' state for that position.

If the current line is in a call to a Lisp function that has a non-nil
property `lisp-indent-function' (or the deprecated `lisp-indent-hook'),
it specifies how to indent.  The property value can be:

* `defun', meaning indent `defun'-style
  \(this is also the case if there is no property and the function
  has a name that begins with \"def\", and three or more arguments);

* an integer N, meaning indent the first N arguments specially
  (like ordinary function arguments), and then indent any further
  arguments like a body;

* a function to call that returns the indentation (or nil).
  `lisp-indent-function' calls this function with the same two arguments
  that it itself received.

This function returns either the indentation to use, or nil if the
Lisp function does not specify a special indentation."
      (let ((normal-indent (current-column))
            (orig-point (point)))
        (goto-char (1+ (elt state 1)))
        (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t)
        (cond
         ;; car of form doesn't seem to be a symbol, or is a keyword
         ((and (elt state 2)
               (or (not (looking-at "\\sw\\|\\s_"))
                   (looking-at ":")))
          (if (not (> (save-excursion (forward-line 1) (point))
                      calculate-lisp-indent-last-sexp))
              (progn (goto-char calculate-lisp-indent-last-sexp)
                     (beginning-of-line)
                     (parse-partial-sexp (point)
                                         calculate-lisp-indent-last-sexp 0 t)))
          ;; Indent under the list or under the first sexp on the same
          ;; line as calculate-lisp-indent-last-sexp.  Note that first
          ;; thing on that line has to be complete sexp since we are
          ;; inside the innermost containing sexp.
          (backward-prefix-chars)
          (current-column))
         ((and (save-excursion
                 (goto-char indent-point)
                 (skip-syntax-forward " ")
                 (not (looking-at ":")))
               (save-excursion
                 (goto-char orig-point)
                 (looking-at ":")))
          (save-excursion
            (goto-char (+ 2 (elt state 1)))
            (current-column)))
         (t
          (let ((function (buffer-substring (point)
                                            (progn (forward-sexp 1) (point))))
                method)
            (setq method (or (function-get (intern-soft function)
                                           'lisp-indent-function)
                             (get (intern-soft function) 'lisp-indent-hook)))
            (cond ((or (eq method 'defun)
                       (and (null method)
                            (length> function 3)
                            (string-match "\\`def" function)))
                   (lisp-indent-defform state indent-point))
                  ((integerp method)
                   (lisp-indent-specform method state
                                         indent-point normal-indent))
                  (method
                   (funcall method indent-point state))))))))

    (setq lisp-indent-function #'my/lisp-indent-function)))

;; Interactive macro expander
(use-package macrostep
  :bind (:map emacs-lisp-mode-map
         ("C-c e" . macrostep-expand)
         :map lisp-interaction-mode-map
         ("C-c e" . macrostep-expand)))

(use-package help-mode
  :ensure nil
  :hook (help-mode . cursor-sensor-mode)
  :bind (:map help-mode-map
         ("r" . remove-hook-at-point))
  :config
  (with-no-warnings
    ;; Add remove buttons for advices
    (defun function-advices (function)
      "Return FUNCTION's advices."
      (let ((flist (indirect-function function)) advices)
        (while (advice--p flist)
          (setq advices `(,@advices ,(advice--car flist)))
          (setq flist (advice--cdr flist)))
        advices))

    (defun help--update ()
      "Update the help buffer."
      (if (eq major-mode 'helpful-mode)
          (helpful-update)
        (revert-buffer nil t)))

    (defun add-remove-advice-button (advice function)
      (when (and (functionp advice) (functionp function))
        (let ((inhibit-read-only t)
              (msg (format "Remove advice `%s'" advice)))
          (insert "\t")
          (insert-button
           "Remove"
           'face 'custom-button
           'cursor-sensor-functions `((lambda (&rest _) ,msg))
           'help-echo msg
           'action (lambda (_)
                     (when (yes-or-no-p msg)
                       (message "%s from function `%s'" msg function)
                       (advice-remove function advice)
                       (help--update)))
           'follow-link t))))

    (defun add-button-to-remove-advice (buffer-or-name function)
      "Add a button to remove advice."
      (with-current-buffer buffer-or-name
        (save-excursion
          (goto-char (point-min))
          (let ((ad-list (function-advices function)))
            (while (re-search-forward "^\\(?:This function has \\)?:[-a-z]+ advice: \\(.+\\)$" nil t)
              (let ((advice (car ad-list)))
                (add-remove-advice-button advice function)
                (setq ad-list (delq advice ad-list))))))))

    (define-advice describe-function-1 (:after (function) advice-remove-button)
      (add-button-to-remove-advice (help-buffer) function))
    (with-eval-after-load 'helpful
      (define-advice helpful-update (:after () advice-remove-button)
        (when helpful--callable-p
          (add-button-to-remove-advice (current-buffer) helpful--sym))))

    ;; Remove hooks
    (defun remove-hook-at-point ()
      "Remove the hook at the point in the *Help* buffer."
      (interactive)
      (unless (memq major-mode '(help-mode helpful-mode))
        (error "Only for help-mode or helpful-mode"))

      (let ((orig-point (point)))
        (save-excursion
          (when-let*
              ((hook (progn (goto-char (point-min)) (symbol-at-point)))
               (func (when (and
                            (or (re-search-forward (format "^Value:?[\s|\n]") nil t)
                                (goto-char orig-point))
                            (thing-at-point 'sexp))
                       (thing-at-point--end-of-sexp)
                       (backward-char 1)
                       (catch 'break
                         (while t
                           (condition-case _err
                               (backward-sexp)
                             (scan-error (throw 'break nil)))
                           (let ((bounds (bounds-of-thing-at-point 'sexp)))
                             (when (<= (car bounds) orig-point (cdr bounds))
                               (throw 'break (thing-at-point 'sexp)))))))))
            (when (yes-or-no-p (format "Remove %s from %s? " func hook))
              (remove-hook hook (intern func))
              (help--update))))))))

;; A better *Help* buffer
(use-package helpful
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-command]  . helpful-command)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key]      . helpful-key)
         ([remap describe-symbol]   . helpful-symbol)
         :map emacs-lisp-mode-map
         ("C-c C-d"                 . helpful-at-point)
         :map lisp-interaction-mode-map
         ("C-c C-d"                 . helpful-at-point)
         :map helpful-mode-map
         ("C-x K"                   . helpful-kill-buffers)
         ("r"                       . remove-hook-at-point))
  :hook (helpful-mode . cursor-sensor-mode)
  :init (with-eval-after-load 'apropos
          ;; patch apropos buttons to call helpful instead of help
          (dolist (fun-bt '(apropos-function apropos-macro apropos-command))
            (button-type-put
             fun-bt 'action
             (lambda (button)
               (helpful-callable (button-get button 'apropos-symbol)))))
          (dolist (var-bt '(apropos-variable apropos-user-option))
            (button-type-put
             var-bt 'action
             (lambda (button)
               (helpful-variable (button-get button 'apropos-symbol)))))))

;; C/C++ Mode
(use-package cc-mode
  :init (setq-default c-basic-offset 4))

(when (centaur-treesit-available-p)
  (use-package c-ts-mode
    :functions centaur-treesit-available-p
    :init
    (setq c-ts-indent-offset 4)

    (when (boundp 'major-mode-remap-alist)
      (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
      (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
      (add-to-list 'major-mode-remap-alist
                   '(c-or-c++-mode . c-or-c++-ts-mode)))))

;; Golang. Its tools (gopls, dlv, ...) come from Nix (development/languages.nix).
(defun go-auto-config ()
  "Configure Golang automatically."
  ;; Env vars
  (with-eval-after-load 'exec-path-from-shell
    (exec-path-from-shell-copy-envs '("GOPATH" "GO111MODULE" "GOPROXY")))

  ;; Misc. tools
  (use-package go-fill-struct)

  (use-package go-gen-test
    :bind (:map go-ts-mode-map
           ("C-c t g" . go-gen-test-dwim)))

  (use-package gotest
    :bind (:map go-ts-mode-map
           ("C-c t f" . go-test-current-file)
           ("C-c t t" . go-test-current-test)
           ("C-c t j" . go-test-current-project)
           ("C-c t b" . go-test-current-benchmark)
           ("C-c t c" . go-test-current-coverage)
           ("C-c t x" . go-run))))

(use-package go-ts-mode
  :defer t
  :functions exec-path-from-shell-copy-envs
  :custom (go-ts-mode-indent-offset 4)
  :config (go-auto-config))

;; Rust
(use-package rust-mode
  :defer t
  :functions centaur-treesit-available-p
  :init (setq rust-format-on-save t
              rust-mode-treesitter-derive (centaur-treesit-available-p)))

(use-package ron-mode
  :mode ("\\.ron"))

;; Python Mode
(use-package python
  :ensure nil
  :defines eglot-server-programs
  :functions exec-path-from-shell-copy-env
  ;; Don't ask about the Python shell when quitting. (Centaur's version
  ;; looked up a process named "Python", which broke Org's named sessions.)
  :hook (inferior-python-mode . (lambda ()
                                  (when-let* ((process (get-buffer-process
                                                        (current-buffer))))
                                    (set-process-query-on-exit-flag process nil))))
  :init
  ;; Disable readline based native completion
  (setq python-shell-completion-native-enable nil)
  :config
  ;; Type checker & language server: `ty'
  (when (executable-find "ty")
    (with-eval-after-load 'eglot
      (add-to-list 'eglot-server-programs
                   '((python-mode python-ts-mode)
                     . ("ty" "server")))))

  ;; Linter & formatter: `ruff'
  (when (executable-find "ruff")
    (use-package flymake-ruff
      :hook (python-base-mode . flymake-ruff-load)))

  ;; Default to Python 3. Prefer the versioned Python binaries since some
  ;; systems stupidly make the unversioned one point at Python 2.
  (when (and (executable-find "python3")
             (string= python-shell-interpreter "python"))
    (setq python-shell-interpreter "python3"))

  ;; Env vars
  (with-eval-after-load 'exec-path-from-shell
    (exec-path-from-shell-copy-env "PYTHONPATH")))

(when (centaur-treesit-available-p)
  (use-package ruby-ts-mode
    :functions centaur-treesit-available-p
    :mode ("\\(?:\\.\\(?:rbw?\\|ru\\|rake\\|thor\\|axlsx\\|jbuilder\\|rabl\\|\
gemspec\\|podspec\\)\\|/\\(?:Gem\\|Rake\\|Cap\\|Thor\\|Puppet\\|Berks\\|Brew\\|\
Fast\\|Vagrant\\|Guard\\|Pod\\)file\\)\\'")
    :init (add-to-list 'major-mode-remap-alist '(ruby-mode . ruby-ts-mode))))

;; Run a Ruby process in a buffer
(use-package inf-ruby
  :bind (:map inf-ruby-minor-mode-map
         ("C-c C-s" . inf-ruby-console-auto))
  :hook ((ruby-mode . inf-ruby-minor-mode)
         (compilation-filter . inf-ruby-auto-enter)))

;; Ruby YARD comments
(use-package yard-mode
  :hook (ruby-mode . yard-mode))

;; Ruby refactoring helpers
(use-package ruby-refactor
  :hook (ruby-mode . ruby-refactor-mode-launch))

;; Yet Another RI interface for Emacs
(use-package yari
  :bind (:map ruby-mode-map ([f1] . yari)))

;; RSpec
(use-package rspec-mode
  :defer t
  :autoload rspec-install-snippets
  :config (rspec-install-snippets))

(defun elixir-auto-config ()
  "Configure elixir automatically."
  (use-package alchemist
    :hook ((elixir-mode elixir-ts-mode)
           (alchemist-mode . alchemist-phoenix-mode))))

(use-package elixir-ts-mode
  :defer t
  :config (elixir-auto-config))

;; eww
(use-package eww
  :init
  ;; Install: npm install -g readability-cli
  (when (executable-find "readable")
    (setq eww-retrieve-command '("readable"))))

;; Webkit browser

;; CSS
(use-package css-mode
  :init (setq css-indent-offset 2))

;; SCSS
;; scss-mode still registers with Flymake's old backend, whose variables
;; are gone from Emacs 31. (Centaur's xwidget browser is left out: this
;; Emacs has no WebKit.)
(defvar flymake-allowed-file-name-masks nil)
(defvar flymake-err-line-patterns nil)
(use-package scss-mode
  :defer t
  :init (setq scss-compile-at-save nil))

;; JavaScript
(use-package js
  :init (setq js-indent-level 2))

;; Major mode for CoffeeScript code
(use-package coffee-mode
  :defer t
  :config (setq coffee-tab-width 2))

;; Major mode for editing web templates
(use-package web-mode
  :mode "\\.\\(phtml\\|php\\|[gj]sp\\|as[cp]x\\|erb\\|djhtml\\|html?\\|\
hbs\\|ejs\\|jade\\|swig\\|tm?pl\\|vue\\)$"
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

;; Adds node_modules/.bin directory to `exec_path'
(use-package add-node-modules-path
  :hook ((web-mode js-base-mode) . add-node-modules-path))

(use-package haml-mode :defer t)
(use-package php-mode :defer t)

;; REST
(use-package restclient
  :mode ("\\.http\\'" . restclient-mode))


;; More major modes (init-prog.el); each loads with its first file.
(use-package cask-mode :defer t)
(use-package cmake-mode :defer t)
(use-package csv-mode :defer t)
(use-package cue-sheet-mode :defer t)
(use-package lua-mode :defer t)
(use-package v-mode :defer t)
(use-package vimrc-mode :defer t)
(use-package powershell
  :defer t
  :custom (explicit-pwsh.exe-args explicit-powershell.exe-args))
(use-package mermaid-ts-mode
  :mode ("\\.mmd\\'"))
(use-package scala-ts-mode :defer t)
(use-package swift-ts-mode
  :mode ("\\.swift\\'"))
(use-package protobuf-mode
  :hook (protobuf-mode
         .
         (lambda ()
           "Set up Protobuf's imenu generic expressions."
           (setq imenu-generic-expression
                 '((nil "^[[:space:]]*\\(message\\|service\\|enum\\)\
[[:space:]]+\\([[:alnum:]]+\\)" 2))))))
(use-package nxml-mode
  :ensure nil
  :mode ("\\.xaml\\'"))
(use-package fish-mode
  :commands fish_indent-before-save
  :defines eglot-server-programs
  :hook (fish-mode . (lambda ()
                       "Integrate `fish_indent` formatting with Fish shell mode."
                       (add-hook 'before-save-hook #'fish_indent-before-save)))
  :config
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '(fish-mode . ("fish-lsp" "start")))))

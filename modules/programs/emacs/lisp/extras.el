;;; extras.el -*- lexical-binding: t -*-

;; Borrowed from Centaur Emacs, minus what meow already does (expand-region,
;; multiple-cursors, iedit, easy-kill, drag-stuff). Keys are in keys.el.

;;; Moving around
(use-package avy                        ; jump to any visible spot
  :commands (avy-goto-char-timer avy-goto-line)
  :custom (avy-style 'pre) (avy-background t) (avy-timeout-seconds 0.4))
(use-package symbol-overlay             ; highlight the symbol at point
  :hook (prog-mode . symbol-overlay-mode)
  :commands (symbol-overlay-put symbol-overlay-remove-all)
  :custom (symbol-overlay-idle-time 0.3))
(use-package goto-chg :commands (goto-last-change goto-last-change-reverse))
(add-hook 'prog-mode-hook #'subword-mode) ; words stop at CamelCase humps

;;; Editing safety nets
(use-package vundo :commands vundo)     ; the undo tree, visually
(use-package sudo-edit :commands sudo-edit)
(setq kill-ring-max 200
      save-interprogram-paste-before-kill t)
(global-so-long-mode 1)                 ; minified files stay responsive
(editorconfig-mode 1)                   ; follow each project's .editorconfig

;;; Seeing more
(use-package indent-bars
  :hook ((prog-mode yaml-ts-mode) . indent-bars-mode)
  :custom (indent-bars-treesit-support t) (indent-bars-no-descend-lists t))
(use-package colorful-mode              ; colour codes shown in their colour
  :demand t
  :config (global-colorful-mode 1))
(use-package pulsar                     ; flash the line after a jump
  :demand t
  :config (pulsar-global-mode 1))
(use-package goggles                    ; flash what was just changed
  :hook ((prog-mode text-mode) . goggles-mode)
  :custom (goggles-pulse t))
(use-package flyover                    ; errors inline, next to the code
  :hook (flymake-mode . flyover-mode)
  :custom (flyover-checkers '(flymake)))
(use-package olivetti :commands olivetti-mode)

;;; Windows
(winner-mode 1)                         ; undo / redo window layouts
(use-package ace-window
  :commands ace-window
  :custom (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))
;; Popups (help, compilation, messages): toggle and cycle them; where they
;; open is still the side-window rules in ui.el.
(use-package popper
  :demand t
  :custom
  (popper-display-control nil)
  (popper-reference-buffers '("\\*Messages\\*" "Output\\*$" "\\*Async Shell Command\\*"
                              "\\*Warnings\\*" "\\*eldoc.*\\*"
                              help-mode helpful-mode compilation-mode))
  :config
  (popper-mode 1)
  (require 'popper-echo)
  (popper-echo-mode 1))

;;; Acting on things
;; C-. acts on whatever is at point or selected in a list (open, copy,
;; rename, export to an editable buffer...); C-h B lists every key.
(use-package embark
  :bind (("C-." . embark-act)
         ("C-h B" . embark-bindings)))
(use-package embark-consult :after (embark consult))
;; In any file prompt: C-x C-d jumps to a recent or project directory.
(use-package consult-dir
  :after vertico
  :bind (:map vertico-map
              ("C-x C-d" . consult-dir)
              ("C-x C-j" . consult-dir-jump-file)))
;; Search results (grep, or consult-ripgrep exported with embark) become
;; editable: change them and save across files.
(use-package wgrep
  :demand t
  :custom (wgrep-auto-save-buffer t))

;;; Git
(use-package git-timemachine :commands git-timemachine)
(use-package browse-at-remote :commands browse-at-remote)
(use-package git-modes :demand t)       ; .gitignore, .gitconfig, ...
(with-eval-after-load 'magit
  (require 'magit-todos)
  (magit-todos-mode 1))

;;; Running code
(use-package quickrun :commands quickrun)

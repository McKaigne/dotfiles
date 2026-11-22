;;; editing.el -*- lexical-binding: t -*-

(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 100)
(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'prog-mode-hook #'hs-minor-mode)
(electric-pair-mode 1)
(show-paren-mode 1)
(delete-selection-mode 1)

(use-package undo-fu-session
  :demand t
  :custom (undo-fu-session-directory (lysec-state-file "undo/"))
  :config (undo-fu-session-global-mode 1))
;; Meow as documented (KEYBINDING_QWERTY.org): the official QWERTY layout and
;; leader, and the default keypad (x/c/h/m/g → C-x/C-c/C-h/M-/C-M-, any other
;; letter → the leader, C-c <letter>). Own leader keys are in keys.el.
(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
        meow-cheatsheet-physical-layout meow-cheatsheet-physical-layout-ansi)
  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; SPC 0-9: digit arguments.
   '("1" . meow-digit-argument) '("2" . meow-digit-argument)
   '("3" . meow-digit-argument) '("4" . meow-digit-argument)
   '("5" . meow-digit-argument) '("6" . meow-digit-argument)
   '("7" . meow-digit-argument) '("8" . meow-digit-argument)
   '("9" . meow-digit-argument) '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0) '("9" . meow-expand-9) '("8" . meow-expand-8)
   '("7" . meow-expand-7) '("6" . meow-expand-6) '("5" . meow-expand-5)
   '("4" . meow-expand-4) '("3" . meow-expand-3) '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing) '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing) '("]" . meow-end-of-thing)
   '("a" . meow-append) '("A" . meow-open-below)
   '("b" . meow-back-word) '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete) '("D" . meow-backward-delete)
   '("e" . meow-next-word) '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection) '("G" . meow-grab)
   '("h" . meow-left) '("H" . meow-left-expand)
   '("i" . meow-insert) '("I" . meow-open-above)
   '("j" . meow-next) '("J" . meow-next-expand)
   '("k" . meow-prev) '("K" . meow-prev-expand)
   '("l" . meow-right) '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block) '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace) '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo) '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word) '("W" . meow-mark-symbol)
   '("x" . meow-line) '("X" . meow-goto-line)
   '("y" . meow-save) '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :demand t
  :custom (meow-use-clipboard t)
  :config
  (meow-setup)
  (meow-global-mode 1))
(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))
(use-package hl-todo :hook (prog-mode . hl-todo-mode))

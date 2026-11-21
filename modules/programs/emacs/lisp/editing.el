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
(use-package meow
  :demand t
  :custom (meow-use-clipboard t)
  :config
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
        meow-cheatsheet-physical-layout meow-cheatsheet-physical-layout-ansi)
  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (dotimes (digit 10)
    (meow-normal-define-key
     (cons (number-to-string digit) (intern (format "meow-expand-%s" digit)))))
  (meow-normal-define-key
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
   '("<escape>" . ignore))
  (dolist (entry '((dired-mode . motion) (treemacs-mode . motion)
                   (magit-mode . motion) (org-agenda-mode . motion)
                   (lysec-dashboard-mode . motion) (eshell-mode . insert)))
    (add-to-list 'meow-mode-state-list entry))
  (meow-global-mode 1))
(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))
(use-package hl-todo :hook (prog-mode . hl-todo-mode))

;;; editing.el -*- lexical-binding: t -*-

(setq display-line-numbers-type 'relative)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

(defun nixmacs-detect-indent-tabs ()
  "Indent with tabs when most indented lines in the buffer already do."
  (save-excursion
    (goto-char (point-min))
    (let ((tabs 0) (spaces 0))
      (while (and (< (+ tabs spaces) 200)
                  (re-search-forward "^\\(?:\\(\t\\)\\|  \\)" nil t))
        (if (match-beginning 1) (setq tabs (1+ tabs)) (setq spaces (1+ spaces))))
      (when (> tabs spaces)
        (setq-local indent-tabs-mode t)))))

(add-hook 'prog-mode-hook #'nixmacs-detect-indent-tabs -50)
(add-hook 'conf-mode-hook #'nixmacs-detect-indent-tabs -50)

(defun meow-setup ()
  "Meow's QWERTY layout, from its documentation."
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . nixmacs-change)
   '("d" . nixmacs-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(defun nixmacs-delete ()
  "Delete the selection and save it to the kill ring, as in Helix."
  (interactive)
  (if (region-active-p)
      (let ((select-enable-clipboard meow-use-clipboard))
        (kill-region (region-beginning) (region-end)))
    (meow-delete)))

(defun nixmacs-change ()
  "Change the selection and save it to the kill ring, as in Helix."
  (interactive)
  (if (region-active-p) (meow-change-save) (meow-change)))

(use-package meow
  :demand t
  :custom
  (meow-use-clipboard t)
  (meow-cheatsheet-physical-layout meow-cheatsheet-physical-layout-ansi)
  (meow-expand-hint-remove-delay 1.5)
  (meow-keypad-describe-delay 0.4)
  :config
  (meow-setup)
  (setq meow--kbd-raise-sexp #'raise-sexp
        meow--kbd-join-sexp #'ignore)
  (dolist (entry '((ghostel-mode . insert)
                   (eshell-mode . insert)
                   (dashboard-mode . motion)
                   (dired-mode . motion)
                   (help-mode . motion)
                   (helpful-mode . motion)
                   (magit-mode . motion)
                   (org-agenda-mode . motion)
                   (eww-mode . motion)))
    (add-to-list 'meow-mode-state-list entry))
  (meow-global-mode 1))

(use-package which-key
  :demand t
  :custom
  (which-key-idle-delay 0.4)
  (which-key-sort-order 'which-key-key-order-alpha)
  (which-key-add-column-padding 2)
  (which-key-side-window-max-height 0.6)
  :config
  (add-to-list 'which-key-replacement-alist
               '((nil . "\\`meow-digit-argument\\'") . t))
  (which-key-mode 1))

(defun nixmacs-escape-quits-read (char)
  "Quit when CHAR, a key just read, is Esc; otherwise return CHAR."
  (if (memq char '(?\e escape)) (signal 'quit nil) char))

(advice-add 'read-char-exclusive :filter-return #'nixmacs-escape-quits-read)
(advice-add 'read-char :filter-return #'nixmacs-escape-quits-read)

(defun nixmacs-escape-quits-events (fn &rest args)
  "Call FN with ARGS, quitting when Esc is read as an event."
  (advice-add 'read-event :filter-return #'nixmacs-escape-quits-read)
  (unwind-protect (apply fn args)
    (advice-remove 'read-event #'nixmacs-escape-quits-read)))

(with-eval-after-load 'ox
  (advice-add 'org-export--dispatch-action :around #'nixmacs-escape-quits-events))

(defun nixmacs-escape-insert ()
  "Close the completion popup and return to normal state."
  (interactive)
  (when (bound-and-true-p completion-in-region-mode)
    (corfu-quit))
  (when (meow-insert-mode-p)
    (meow-insert-exit)))

(defun nixmacs-escape-normal ()
  "Cancel the selection, or close the documentation popup."
  (interactive)
  (cond ((region-active-p) (meow-cancel-selection))
        ((and (fboundp 'eldoc-box-quit-frame)
              (bound-and-true-p eldoc-box--frame)
              (frame-visible-p eldoc-box--frame))
         (eldoc-box-quit-frame))))

(defun nixmacs-escape-motion ()
  "Leave the tool buffer shown in this window."
  (interactive)
  (cond ((derived-mode-p 'dashboard-mode) (nixmacs-quit-dashboard))
        ((and (derived-mode-p 'dired-mode) (fboundp 'dirvish-curr) (dirvish-curr))
         (dirvish-quit))
        ((derived-mode-p 'org-agenda-mode) (org-agenda-quit))
        ((region-active-p) (meow-cancel-selection))
        (t (quit-window))))

(keymap-set meow-insert-state-keymap "<escape>" #'nixmacs-escape-insert)
(keymap-set meow-normal-state-keymap "<escape>" #'nixmacs-escape-normal)
(keymap-set meow-motion-state-keymap "<escape>" #'nixmacs-escape-motion)

(define-key function-key-map [escape] nil)
(keymap-global-set "<escape>" #'keyboard-quit)
(dolist (map (list minibuffer-local-map read-expression-map))
  (keymap-set map "<escape>" #'abort-minibuffers))
(keymap-set isearch-mode-map "<escape>" #'isearch-cancel)

(with-eval-after-load 'embark
  (keymap-set embark-general-map "<escape>" #'abort-recursive-edit))

(with-eval-after-load 'transient
  (keymap-set transient-map "<escape>" #'transient-quit-one))

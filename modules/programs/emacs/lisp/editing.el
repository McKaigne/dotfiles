;;; editing.el -*- lexical-binding: t -*-

(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 100)
(setq display-line-numbers-type 'relative)

(use-package undo-fu-session
  :demand t
  :custom (undo-fu-session-directory (my-state-file "undo/"))
  :config (undo-fu-session-global-mode 1))
;; Meow, as Ly-sec set it up: the QWERTY layout, tool buffers in motion
;; state, shells in insert. The Space menu is in keys.el.
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
                   (dashboard-mode . motion) (eshell-mode . insert)
                   (ghostel-mode . insert) (helpful-mode . motion)))
    (add-to-list 'meow-mode-state-list entry))
  (meow-global-mode 1))
;; Centaur Emacs's editing and kill-ring modules (lisp/init-edit.el,
;; lisp/init-kill-ring.el). Its hydras (rectangle, multiple cursors,
;; folding) are Meow menus here, opened from the Space menu (keys.el);
;; its global keys are kept as they are, and work in every Meow state.
;; Left out: ace-pinyin (Chinese input) and xclip (core.el already talks to
;; the Wayland clipboard).

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(use-package rect
  :ensure nil
  :bind (:map text-mode-map
         ("<C-return>" . my-rectangle-menu)
         :map prog-mode-map
         ("<C-return>" . my-rectangle-menu))
  :init
  (with-eval-after-load 'org
    (bind-key "<s-return>" #'my-rectangle-menu org-mode-map))
  (with-eval-after-load 'wgrep
    (bind-key "<C-return>" #'my-rectangle-menu wgrep-mode-map))
  (with-eval-after-load 'wdired
    (bind-key "<C-return>" #'my-rectangle-menu wdired-mode-map)))
(my-define-menu my-rectangle-menu "Rectangle"
  :pre (rectangle-mark-mode 1)
  :post (deactivate-mark)
  ("h" #'backward-char "←")
  ("j" #'next-line "↓")
  ("k" #'previous-line "↑")
  ("l" #'forward-char "→")
  ("w" #'copy-rectangle-as-kill "copy")
  ("y" #'yank-rectangle "yank")
  ("t" #'string-rectangle "string")
  ("d" #'kill-rectangle "kill")
  ("c" #'clear-rectangle "clear")
  ("o" #'open-rectangle "open")
  ("N" #'rectangle-number-lines "number lines")
  ("e" #'rectangle-exchange-point-and-mark "exchange")
  ("u" #'undo "undo")
  ("r" (lambda () (interactive)
         (if (region-active-p) (deactivate-mark) (rectangle-mark-mode 1)))
   "reset"))

(use-package autorevert
  :ensure nil
  :hook (after-init . global-auto-revert-mode))

(use-package browse-url
  :ensure nil
  :bind (("C-c C-z ." . browse-url-at-point)
         ("C-c C-z b" . browse-url-of-buffer)
         ("C-c C-z r" . browse-url-of-region)
         ("C-c C-z u" . browse-url)
         ("C-c C-z e" . browse-url-emacs)
         ("C-c C-z v" . browse-url-of-file))
  :init
  (with-eval-after-load 'dired
    (bind-key "C-c C-z f" #'browse-url-of-file dired-mode-map)))

(use-package goto-addr
  :ensure nil
  :hook (prog-mode . goto-address-prog-mode))

(use-package avy
  :bind (("C-:"   . avy-goto-char)
         ("C-'"   . avy-goto-char-2)
         ("M-g l" . avy-goto-line)
         ("M-g w" . avy-goto-word-1)
         ("M-g e" . avy-goto-word-0))
  :hook (after-init . avy-setup-default)
  :config (setq avy-all-windows nil
                avy-all-windows-alt t
                avy-background t
                avy-style 'pre))

(use-package avy-zap
  :bind (("M-z" . avy-zap-to-char-dwim)
         ("M-Z" . avy-zap-up-to-char-dwim)))

(use-package link-hint
  :bind (("M-o"     . link-hint-open-link)
         ("C-c l o" . link-hint-open-link)
         ("C-c l c" . link-hint-copy-link))
  :init
  (with-eval-after-load 'compile
    (bind-key "o" #'link-hint-open-link compilation-mode-map))
  (with-eval-after-load 'cus-edit
    (bind-key "o" #'link-hint-open-link custom-mode-map))
  (with-eval-after-load 'elfeed-show
    (bind-key "o" #'link-hint-open-link elfeed-show-mode-map))
  (with-eval-after-load 'eww
    (bind-key "o" #'link-hint-open-link eww-mode-map))
  (with-eval-after-load 'help
    (bind-key "o" #'link-hint-open-link help-mode-map))
  (with-eval-after-load 'helpful
    (bind-key "o" #'link-hint-open-link helpful-mode-map))
  (with-eval-after-load 'info
    (bind-key "o" #'link-hint-open-link Info-mode-map))
  (with-eval-after-load 'nov
    (bind-key "o" #'link-hint-open-link nov-mode-map))
  (with-eval-after-load 'woman
    (bind-key "o" #'link-hint-open-link woman-mode-map))
  (with-eval-after-load 'xref
    (bind-key "o" #'link-hint-open-link xref--xref-buffer-mode-map))
  (with-eval-after-load 'embark
    (setq link-hint-action-fallback-commands
          (list :open (lambda ()
                        (condition-case _
                            (progn
                              (embark-dwim)
                              t)
                          (error
                           nil)))))))

(use-package anzu
  :bind (([remap query-replace] . anzu-query-replace)
         ([remap query-replace-regexp] . anzu-query-replace-regexp)
         :map isearch-mode-map
         ([remap isearch-query-replace] . anzu-isearch-query-replace)
         ([remap isearch-query-replace-regexp] . anzu-isearch-query-replace-regexp))
  :hook (after-init . global-anzu-mode))

(use-package beginend
  :hook (after-init . beginend-global-mode))

(use-package drag-stuff
  :autoload drag-stuff-define-keys
  :hook (after-init . drag-stuff-global-mode)
  :config
  (add-to-list 'drag-stuff-except-modes 'org-mode)
  (drag-stuff-define-keys))

(use-package ediff
  :ensure nil
  :hook ((ediff-prepare-buffer . outline-show-all)
         (ediff-quit . winner-undo))
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain
        ediff-split-window-function 'split-window-horizontally
        ediff-merge-split-window-function 'split-window-horizontally))

(use-package elec-pair
  :hook (after-init . electric-pair-mode)
  :init (setq electric-pair-inhibit-predicate 'electric-pair-conservative-inhibit))

(use-package ialign :commands ialign)

(use-package iedit
  :bind (:map global-map
         ("C-;" . iedit-mode)
         ("C-x r RET" . iedit-rectangle-mode)
         :map isearch-mode-map ("C-;" . iedit-mode-from-isearch)
         :map esc-map ("C-;" . iedit-execute-last-modification)
         :map help-map ("C-;" . iedit-mode-toggle-on-function)))

(use-package expand-region
  :bind ("C-=" . er/expand-region)
  :config
  (when (centaur-treesit-available-p)
    (defun treesit-mark-bigger-node ()
      "Use tree-sitter to mark regions."
      (let* ((root (treesit-buffer-root-node))
             (node (treesit-node-descendant-for-range root (region-beginning) (region-end)))
             (node-start (treesit-node-start node))
             (node-end (treesit-node-end node)))
        (when (and (= (region-beginning) node-start) (= (region-end) node-end))
          (when-let* ((node (treesit-node-parent node)))
            (setq node-start (treesit-node-start node)
                  node-end (treesit-node-end node))))
        (set-mark node-end)
        (goto-char node-start)))
    (add-to-list 'er/try-expand-list 'treesit-mark-bigger-node)))

(use-package multiple-cursors
  :bind (("C-c m"         . my-multiple-cursors-menu)
         ("C-S-c C-S-c"   . mc/edit-lines)
         ("C->"           . mc/mark-next-like-this)
         ("C-<"           . mc/mark-previous-like-this)
         ("C-c C-<"       . mc/mark-all-like-this)
         ("C-M->"         . mc/skip-to-next-like-this)
         ("C-M-<"         . mc/skip-to-previous-like-this)
         ("s-<mouse-1>"   . mc/add-cursor-on-click)
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)
         :map mc/keymap
         ("C-|" . mc/vertical-align-with-space))
  :custom (mc/list-file (my-state-file "mc-lists.el")))
(my-define-menu my-multiple-cursors-menu "Multiple Cursors"
  ("p" #'mc/mark-previous-like-this "prev")
  ("P" #'mc/skip-to-previous-like-this "skip prev")
  ("M-p" #'mc/unmark-previous-like-this "unmark prev")
  ("|" #'mc/vertical-align "align with input CHAR")
  ("n" #'mc/mark-next-like-this "next")
  ("N" #'mc/skip-to-next-like-this "skip next")
  ("M-n" #'mc/unmark-next-like-this "unmark next")
  ("l" #'mc/edit-lines "edit lines" :exit t)
  ("a" #'mc/mark-all-like-this "mark all" :exit t)
  ("s" #'mc/mark-all-in-region-regexp "search" :exit t)
  ("0" #'mc/insert-numbers "insert numbers" :exit t)
  ("A" #'mc/insert-letters "insert letters" :exit t))

(use-package smart-region
  :hook (after-init . smart-region-on))

;; Spell checking (aspell is on PATH, default.nix).
(use-package flyspell
  :ensure nil
  :if (executable-find "aspell")
  :bind (:map flyspell-mode-map
         ("C-;" . nil)
         ("C-," . nil)
         ("C-." . nil))
  :hook (((text-mode outline-mode) . (lambda ()
                                       "Check spells unless the file is too big."
                                       (unless (file-too-big-p)
                                         (flyspell-mode 1))))
         (prog-mode . flyspell-prog-mode))
  :init (setq flyspell-issue-message-flag nil
              flyspell-issue-welcome-flag nil
              ispell-program-name "aspell"
              ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--run-together")))

(use-package hungry-delete
  :hook (after-init . global-hungry-delete-mode)
  :init (setq hungry-delete-chars-to-skip " \t\f\v"
              hungry-delete-except-modes
              '(help-mode minibuffer-mode minibuffer-inactive-mode calc-mode)))

(use-package mwim
  :bind (([remap move-beginning-of-line] . mwim-beginning)
         ([remap move-end-of-line] . mwim-end)))

(use-package vundo
  :bind ("C-x u" . vundo)
  :config (setq vundo-glyph-alist vundo-unicode-symbols))

(use-package goto-chg
  :bind ("C-," . goto-last-change))

(use-package subword
  :ensure nil
  :hook ((prog-mode minibuffer-setup) . subword-mode))

;; Folding: kirigami works the same over hideshow, outline, Org and
;; tree-sitter; the hideshow menu is hideshow's own commands.
(use-package kirigami
  :custom
  (kirigami-show-menu-bar t)
  (kirigami-show-context-menu t)
  :bind (:map kirigami-mode-map
         ("C-~" . my-kirigami-menu)
         ("M-RET" . my-kirigami-menu)
         ("C-c z o" . kirigami-open-fold)
         ("C-c z O" . kirigami-open-fold-rec)
         ("C-c z r" . kirigami-open-folds)
         ("C-c z c" . kirigami-close-fold)
         ("C-c z m" . kirigami-close-folds)
         ("C-c z a" . kirigami-toggle-fold))
  :hook (after-init . kirigami-global-mode))
(my-define-menu my-kirigami-menu "Kirigami"
  ("o" #'kirigami-open-fold "open fold at point")
  ("O" #'kirigami-open-fold-rec "open fold recursively")
  ("r" #'kirigami-open-folds "open all folds")
  ("c" #'kirigami-close-fold "close fold at point")
  ("m" #'kirigami-close-folds "close all folds")
  ("a" #'kirigami-toggle-fold "toggle fold at point")
  ("C-a" #'mwim-beginning-of-code-or-line "⭰")
  ("C-e" #'mwim-end-of-code-or-line "⭲")
  ("C-b" #'backward-char "←")
  ("C-n" #'next-line "↓")
  ("C-p" #'previous-line "↑")
  ("C-f" #'forward-char "→")
  ("C-v" #'scroll-up-command "↘")
  ("M-v" #'scroll-down-command "↖")
  ("M-<" #'beginning-of-buffer "⭶")
  ("M->" #'end-of-buffer "⭸"))

(use-package hideshow
  :ensure nil
  :bind (:map hs-minor-mode-map
         ("C-S-<escape>" . my-hideshow-menu))
  :hook (prog-mode . hs-minor-mode)
  :config
  (defun hs-cycle (&optional level)
    (interactive "p")
    (let (message-log-max
          (inhibit-message t))
      (if (= level 1)
          (pcase last-command
            ('hs-cycle
             (hs-hide-level 1)
             (setq this-command 'hs-cycle-children))
            ('hs-cycle-children
             (save-excursion (hs-show-block))
             (setq this-command 'hs-cycle-subtree))
            ('hs-cycle-subtree
             (hs-hide-block))
            (_
             (if (not (hs-already-hidden-p))
                 (hs-hide-block)
               (hs-hide-level 1)
               (setq this-command 'hs-cycle-children))))
        (hs-hide-level level)
        (setq this-command 'hs-hide-level))))

  (defun hs-toggle-all ()
    "Toggle hide/show all."
    (interactive)
    (pcase last-command
      ('hs-toggle-all
       (save-excursion (hs-show-all))
       (setq this-command 'hs-global-show))
      (_ (hs-hide-all))))

  ;; Display line counts
  (defun hs-display-code-line-counts (ov)
    "Display line counts when hiding codes."
    (when (eq 'code (overlay-get ov 'hs))
      (overlay-put ov 'display
                   (concat
                    " "
                    (propertize
                     (format "%s(%d lines)..."
                             (and (char-displayable-p ?⏷) "⏷ ")
                             (count-lines (overlay-start ov)
                                          (overlay-end ov)))
                     'face '(:inherit shadow :height 0.8)
                     'mouse-face 'highlight
                     'local-map (let ((map (make-sparse-keymap)))
                                  (define-key map [mouse-1] #'hs-show-block)
                                  map))
                    " "))))
  (setq hs-set-up-overlay #'hs-display-code-line-counts))
(my-define-menu my-hideshow-menu "HideShow"
  ("t" #'hs-toggle-all "toggle all")
  ("a" #'hs-show-all "show all")
  ("i" #'hs-hide-all "hide all")
  ("g" #'hs-toggle-hiding "toggle hiding")
  ("c" #'hs-cycle "cycle block")
  ("s" #'hs-show-block "show block")
  ("h" #'hs-hide-block "hide block")
  ("l" #'hs-hide-level "hide level")
  ("C-a" #'mwim-beginning-of-code-or-line "⭰")
  ("C-e" #'mwim-end-of-code-or-line "⭲")
  ("C-b" #'backward-char "←")
  ("C-n" #'next-line "↓")
  ("C-p" #'previous-line "↑")
  ("C-f" #'forward-char "→")
  ("C-v" #'scroll-up-command "↘")
  ("M-v" #'scroll-down-command "↖")
  ("M-<" #'beginning-of-buffer "⭶")
  ("M->" #'end-of-buffer "⭸"))

(use-package sudo-edit :commands sudo-edit)

(use-package so-long
  :ensure nil
  :hook (after-init . global-so-long-mode))

;; Kill ring
(setq kill-ring-max 200
      save-interprogram-paste-before-kill t)

(use-package easy-kill
  :bind (([remap kill-ring-save] . easy-kill)
         ([remap mark-sexp] . easy-mark)))

(use-package browse-kill-ring
  :bind ("C-c k" . browse-kill-ring)
  :hook (after-init . browse-kill-ring-default-keybindings)
  :init (setq browse-kill-ring-separator "────────────────"
              browse-kill-ring-separator-face 'shadow))

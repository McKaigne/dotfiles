;;; highlight.el -*- lexical-binding: t -*-

;; Centaur Emacs's highlighting (lisp/init-highlight.el). One change for
;; Meow: symbol-overlay's keys stay off the highlighted symbols themselves
;; (they would shadow Meow's i, p, d, w...); they are on M-s s instead.

;; Highlight the current line
(use-package hl-line
  :ensure nil
  :hook (after-init . global-hl-line-mode))
(global-hl-line-mode 1)

;; Highlight matching parens
(use-package paren
  :ensure nil
  :custom-face
  (show-paren-match ((((class color) (background light))
                      (:box (:line-width (-1 . -1) :color "gray73")))
                     (((class color) (background dark))
                      (:box (:line-width (-1 . -1) :color "gray56")))))
  :hook (after-init . show-paren-mode)
  :custom
  (show-paren-when-point-inside-paren t)
  (show-paren-when-point-in-periphery t)
  :config
  (setq blink-matching-paren-highlight-offscreen t
        show-paren-context-when-offscreen
        (if (childframe-workable-p) 'child-frame 'overlay)))
(show-paren-mode 1)

;; Highlight symbols
(use-package symbol-overlay
  :functions (easy-kill easy-kill-destroy-candidate)
  :custom-face
  (symbol-overlay-default-face ((t (:inherit region :background unspecified :foreground unspecified))))
  (symbol-overlay-face-1 ((t (:inherit nerd-icons-blue :background unspecified :foreground unspecified :inverse-video t))))
  (symbol-overlay-face-2 ((t (:inherit nerd-icons-pink :background unspecified :foreground unspecified :inverse-video t))))
  (symbol-overlay-face-3 ((t (:inherit nerd-icons-yellow :background unspecified :foreground unspecified :inverse-video t))))
  (symbol-overlay-face-4 ((t (:inherit nerd-icons-purple :background unspecified :foreground unspecified :inverse-video t))))
  (symbol-overlay-face-5 ((t (:inherit nerd-icons-red :background unspecified :foreground unspecified :inverse-video t))))
  (symbol-overlay-face-6 ((t (:inherit nerd-icons-orange :background unspecified :foreground unspecified :inverse-video t))))
  (symbol-overlay-face-7 ((t (:inherit nerd-icons-green :background unspecified :foreground unspecified :inverse-video t))))
  (symbol-overlay-face-8 ((t (:inherit nerd-icons-cyan :background unspecified :foreground unspecified :inverse-video t))))
  :custom (symbol-overlay-idle-time 0.3)
  :bind (("M-i"  . symbol-overlay-put)
         ("M-n"  . symbol-overlay-jump-next)
         ("M-p"  . symbol-overlay-jump-prev)
         ("M-N"  . symbol-overlay-switch-forward)
         ("M-P"  . symbol-overlay-switch-backward)
         ("M-C"  . symbol-overlay-remove-all)
         ([M-f2] . symbol-overlay-mode)
         ([M-f3] . symbol-overlay-put)
         ([M-f4] . symbol-overlay-remove-all))
  :bind-keymap ("M-s s"  . symbol-overlay-map)
  :hook ((after-change-major-mode . turn-on-symbol-overlay)
         (iedit-mode      . turn-off-symbol-overlay)
         (iedit-mode-end  . turn-on-symbol-overlay))
  :init
  (setq symbol-overlay-inhibit-map t)
  (defun turn-off-symbol-overlay (&rest _)
    "Turn off symbol highlighting."
    (interactive)
    (symbol-overlay-mode -1))

  (defun turn-on-symbol-overlay (&rest _)
    "Turn on symbol highlighting."
    (interactive)
    (when (derived-mode-p 'prog-mode 'yaml-mode 'yaml-ts-mode)
      (symbol-overlay-mode 1)))
  :config
  ;; Disable symbol highlighting while selecting
  (advice-add #'activate-mark :after #'turn-off-symbol-overlay)
  (advice-add #'deactivate-mark :after #'turn-on-symbol-overlay)
  (advice-add #'easy-kill :after #'turn-off-symbol-overlay)
  (advice-add #'easy-kill-destroy-candidate :after #'turn-on-symbol-overlay))

;; Mark occurrences of current region (selection)
(use-package region-occurrences-highlighter
  :bind (:map region-occurrences-highlighter-nav-mode-map
         ("M-n" . region-occurrences-highlighter-next)
         ("M-p" . region-occurrences-highlighter-prev))
  :hook (after-init . global-region-occurrences-highlighter-mode))

;; Show the fill column as a faint line in code
(use-package display-fill-column-indicator
  :ensure nil
  :custom-face (fill-column-indicator ((((class color) (background light))
                                        (:foreground "gray75"))
                                       (((class color) (background dark))
                                        (:foreground "gray25"))))
  :hook (prog-mode . display-fill-column-indicator-mode))

;; Highlight indentions
(use-package indent-bars
  :custom
  (indent-bars-color '(font-lock-comment-face :face-bg nil :blend 0.4))
  (indent-bars-highlight-current-depth '(:face default :blend 0.4))
  (indent-bars-pattern ".")
  (indent-bars-width-frac 0.1)
  (indent-bars-pad-frac 0.1)
  (indent-bars-color-by-depth nil)
  (indent-bars-treesit-support (centaur-treesit-available-p))
  (indent-bars-no-descend-string t)
  (indent-bars-prefer-character t)
  :hook ((prog-mode yaml-mode yaml-ts-mode) . indent-bars-mode))

;; Colorize color names in buffers
(use-package colorful-mode
  :custom
  (colorful-use-prefix t)
  (colorful-prefix-string "■")
  (colorful-only-strings 'only-prog)
  (css-fontify-colors nil)
  :hook (after-init . global-colorful-mode)
  :config
  (add-to-list 'global-colorful-modes 'helpful-mode))

;; Highlight brackets according to their depth
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Highlight TODO and similar keywords in comments and strings
(use-package hl-todo
  :autoload hl-todo-flymake hl-todo-search-and-highlight
  :functions rg rg-read-files rg-project
  :custom-face
  (hl-todo ((t (:inherit default :height 0.9 :width condensed :weight bold :underline nil :inverse-video t))))
  :bind (:map hl-todo-mode-map
         ([C-f3]    . hl-todo-occur)
         ("C-c t o" . hl-todo-occur)
         ("C-c t p" . hl-todo-previous)
         ("C-c t n" . hl-todo-next)
         ("C-c t i" . hl-todo-insert)
         ("C-c t r" . hl-todo-rg-project)
         ("C-c t R" . hl-todo-rg))
  :hook (after-init . global-hl-todo-mode)
  :init (setq hl-todo-require-punctuation t
              hl-todo-highlight-punctuation ":")
  :config
  (dolist (keyword '("BUG" "DEFECT" "ISSUE"))
    (add-to-list 'hl-todo-keyword-faces `(,keyword . "#e45649")))
  (dolist (keyword '("TRICK" "WORKAROUND"))
    (add-to-list 'hl-todo-keyword-faces `(,keyword . "#d0bf8f")))
  (dolist (keyword '("PERF"))
    (add-to-list 'hl-todo-keyword-faces `(,keyword . "#7cb8bb")))

  ;; Highlight TODO keywords in Magit
  (with-eval-after-load 'magit
    (add-hook 'magit-log-wash-summary-hook #'hl-todo-search-and-highlight t)
    (add-hook 'magit-revision-wash-message-hook #'hl-todo-search-and-highlight t))

  ;; Search TODO keywords in rg
  (defun hl-todo-rg (regexp &optional files dir)
    "Use `rg' to find all TODO or similar keywords."
    (interactive
     (progn
       (unless (require 'rg nil t)
         (error "`rg' is not installed"))
       (let ((regexp (replace-regexp-in-string "\\\\[_<>]*" "" (hl-todo--regexp))))
         (list regexp
               (rg-read-files)
               (read-directory-name "Base directory: " nil default-directory t)))))
    (rg regexp files dir))

  (defun hl-todo-rg-project ()
    "Use `rg' to find all TODO or similar keywords in current project."
    (interactive)
    (unless (require 'rg nil t)
      (error "`rg' is not installed"))
    (rg-project (replace-regexp-in-string "\\\\[_<>]*" "" (hl-todo--regexp)) "everything")))

;; Search TODO keywords in consult
(use-package consult-todo
  :bind (("C-c c h" . consult-todo)
         ("C-c c a" . consult-todo-all)
         :map hl-todo-mode-map
         ("C-c t l" . consult-todo)
         ("C-c t a" . consult-todo-all)))

;; Highlight uncommitted changes using VC
(use-package diff-hl
  :custom-face
  (diff-hl-change ((t (:inherit custom-changed :foreground unspecified :background unspecified))))
  (diff-hl-insert ((t (:inherit diff-added :background unspecified))))
  (diff-hl-delete ((t (:inherit diff-removed :background unspecified))))
  :bind (:map diff-hl-command-map
         ("SPC" . diff-hl-mark-hunk))
  :hook ((after-init . global-diff-hl-mode)
         (after-init . global-diff-hl-show-hunk-mouse-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         ((after-init after-load-theme server-after-make-frame) . diff-hl-set-posframe))
  :custom
  (diff-hl-draw-borders nil)
  (diff-hl-update-async t)
  (diff-hl-global-modes '(not image-mode pdf-view-mode))
  :init
  (defun diff-hl-set-posframe ()
    "Set display type and appearance of `diff-hl.'"
    (setq diff-hl-show-hunk-function (if (childframe-workable-p)
                                         'diff-hl-show-hunk-posframe
                                       'diff-hl-show-hunk-inline)
          diff-hl-show-hunk-posframe-internal-border-color
          (face-background 'posframe-border nil t)))
  :config
  ;; Set fringe style
  (setq-default fringes-outside-margins t)

  (defun my/diff-hl-fringe-bmp-function (_type _pos)
    "Fringe bitmap function for use as `diff-hl-fringe-bmp-function'."
    (define-fringe-bitmap 'my/diff-hl-bmp
      (vector #b11111100)
      1 8
      '(center t)))
  (setq diff-hl-fringe-bmp-function #'my/diff-hl-fringe-bmp-function)

  ;; `diff-hl-show-hunk-hide' moves to the original window before hiding
  ;; the popup, so whether the popup had the keys is lost by then; always
  ;; delete it (funcs.el). `posframe-show' makes a new one each time.
  (advice-add 'diff-hl-show-hunk--posframe-hide :around #'my/delete-child-frames)

  ;; Stepping hunks from inside the popup deletes it and shows a new one,
  ;; which posframe doesn't focus; hand it the keys back.
  (defun my/diff-hl-keep-popup-focus (step &rest args)
    "Call STEP with ARGS, refocusing the hunk popup if it had the keys."
    (let ((focused (and (frame-live-p diff-hl-show-hunk--frame)
                        (eq diff-hl-show-hunk--frame (selected-frame)))))
      (apply step args)
      (when (and focused (frame-live-p diff-hl-show-hunk--frame))
        (select-frame-set-input-focus diff-hl-show-hunk--frame))))
  (dolist (step '(diff-hl-show-hunk-next diff-hl-show-hunk-previous))
    (advice-add step :around #'my/diff-hl-keep-popup-focus))

  ;; Update diff-hl in time.
  (diff-hl-flydiff-mode 1))

;; Pulse current line
(use-package pulsar
  :custom-face
  (pulsar-generic ((t :inherit region :extend t)))
  :custom (pulsar-delay 0.03)               ; `pulse-delay's default
  :hook (emacs-startup . pulsar-global-mode))

;; Flash the region just changed (yank, undo, ...)
(use-package goggles
  :hook ((prog-mode text-mode conf-mode) . goggles-mode))

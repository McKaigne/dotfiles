;;; ui.el -*- lexical-binding: t -*-

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" my-config-directory))
(load-theme 'noctalia t)
;; Mode line: doom-modeline set up as in Centaur Emacs (icons, the minor
;; modes collapsed into one menu, a scroll HUD in the bar, none in terminals
;; or the dashboard), taller, with the bar in the theme's accent. Its own
;; segments pad themselves, so they are listed without extra spacers; only
;; the right edge gets a margin.
(use-package doom-modeline
  :demand t
  :custom
  (doom-modeline-height 32)
  (doom-modeline-bar-width 5)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-minor-modes t)
  (doom-modeline-hud t)
  (doom-modeline-project-name nil)
  (doom-modeline-buffer-encoding nil)
  :config
  (doom-modeline-def-segment my-edge
    "Room between the last segment and the window's edge."
    (doom-modeline-wspc))
  ;; A wider gap between an icon and its text: doom-modeline's is half a
  ;; character, and Nerd Font icons spill past their cell, which jammed the
  ;; folder icon against the path. These are its buffer and directory
  ;; segments with only that gap changed.
  (defun my-modeline-icon (icon)
    "ICON and a gap after it, or nothing if ICON is empty."
    (when (and icon (not (string-empty-p icon)))
      (concat icon (propertize " " 'face (doom-modeline-spc-face)
                               'display '(space :width 1.5)))))
  (doom-modeline-def-segment buffer-info
    "The buffer's icon, state (modified, read-only...) and name."
    (concat
     (doom-modeline-spc)
     (when (and doom-modeline-icon doom-modeline-major-mode-icon)
       (when-let* ((icon (or doom-modeline--buffer-file-icon
                             (doom-modeline-update-buffer-file-icon))))
         (my-modeline-icon
          (if doom-modeline-major-mode-color-icon
              (doom-modeline-display-icon icon)
            (doom-modeline-propertize-icon icon (doom-modeline-face))))))
     (when (and doom-modeline-icon doom-modeline-buffer-state-icon
                doom-modeline--buffer-file-state-icon)
       (my-modeline-icon
        (doom-modeline-display-icon doom-modeline--buffer-file-state-icon)))
     (doom-modeline--buffer-name)))
  (defun my-modeline-directory (face &optional state)
    "The folder icon and `default-directory', in FACE.
With STATE, the buffer-state icon too."
    (concat
     (doom-modeline-spc)
     (and doom-modeline-major-mode-icon
          (my-modeline-icon
           (doom-modeline-icon 'octicon "nf-oct-file_directory_fill" "🖿" ""
                               :face face)))
     (and state doom-modeline-icon doom-modeline-buffer-state-icon
          doom-modeline--buffer-file-state-icon
          (my-modeline-icon
           (doom-modeline-display-icon doom-modeline--buffer-file-state-icon)))
     (propertize (abbreviate-file-name default-directory) 'face face)))
  (doom-modeline-def-segment buffer-default-directory
    "The folder icon and `default-directory' (dired, scratch...)."
    (my-modeline-directory
     (doom-modeline-face (if (and buffer-file-name (buffer-modified-p))
                             'doom-modeline-buffer-modified
                           'doom-modeline-buffer-path))
     t))
  (doom-modeline-def-segment buffer-default-directory-simple
    "The folder icon and `default-directory' (the dashboard)."
    (my-modeline-directory (doom-modeline-face 'doom-modeline-buffer-path)))
  ;; doom-modeline's own layouts, minus what the file icon or the rest of
  ;; the frame already says: major-mode name, indentation, word count,
  ;; clock. These replace its 'main, 'special (help, magit, ...) and
  ;; 'project (dired) layouts, so every buffer gets them.
  (doom-modeline-def-modeline 'main
    '(bar window-state modals matches follow buffer-info remote-host buffer-position selection-info)
    '(compilation misc-info repl lsp minor-modes input-method process vcs check my-edge))
  (doom-modeline-def-modeline 'special
    '(bar window-state modals matches buffer-info remote-host buffer-position selection-info)
    '(compilation misc-info minor-modes input-method process my-edge))
  (doom-modeline-def-modeline 'project
    '(bar window-state modals buffer-default-directory remote-host buffer-position)
    '(compilation misc-info minor-modes input-method process vcs my-edge))
  (doom-modeline-mode 1))
;; Minor modes collapse into one menu, except Markdown's table and code
;; block modes, which say where you are.
(setq mode-line-collapse-minor-modes '(not markdown-ts-code-block-in-context-mode
                                           markdown-ts-in-table-mode))
;; No mode line where it adds nothing (Centaur's list, plus the file tree).
;; The dashboard keeps doom-modeline's own short one, as in Centaur.
(dolist (hook '(eshell-mode-hook ghostel-mode-hook shell-mode-hook term-mode-hook
                embark-collect-mode-hook pdf-annot-list-mode-hook
                treemacs-mode-hook))
  (add-hook hook #'mode-line-invisible-mode))

;; Centaur's frame and redisplay settings.
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil
      fast-but-imprecise-scrolling t
      redisplay-skip-fontification-on-input t)
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
(setq frame-resize-pixelwise t
      frame-title-format '("Emacs - %b")
      icon-title-format frame-title-format)
(setq use-file-dialog nil
      use-dialog-box nil
      inhibit-startup-screen t
      inhibit-default-init t
      initial-scratch-message nil)
(unless (daemonp)
  (advice-add #'display-startup-echo-area-message :override #'ignore))

;; The bell flashes the mode line (doom-themes' visual bell, without its
;; themes).
(use-package doom-themes-ext-visual-bell
  :ensure nil
  :demand t
  :config (doom-themes-visual-bell-config))

(use-package time
  :init (setq display-time-default-load-average nil
              display-time-format "%H:%M"))

(require 'disp-table)
(unless standard-display-table
  (setq standard-display-table (make-display-table)))
(set-display-table-slot standard-display-table 'vertical-border
                        (make-glyph-code ?│ 'vertical-border))

(defun my-style-panes (&rest _)
  "Keep pane boundaries visible using colors from the active theme."
  (let ((border (face-foreground 'shadow nil t))
        (active-background (face-background 'mode-line nil t))
        (active-foreground (face-foreground 'mode-line nil t))
        (inactive-background (face-background 'corfu-default nil t)))
    (set-face-attribute 'vertical-border nil
                        :foreground border
                        :background (face-background 'default nil t))
    (set-face-attribute 'mode-line-active nil
                        :background active-background
                        :foreground active-foreground :box nil)
    (set-face-attribute 'mode-line-inactive nil
                        :background inactive-background :box nil)
    (dolist (face '(window-divider window-divider-first-pixel window-divider-last-pixel))
      (set-face-attribute face nil :foreground border))
    ;; The mode line's bar (and its scroll HUD) in the theme's accent.
    (when (facep 'doom-modeline-bar)
      (set-face-attribute 'doom-modeline-bar nil
                          :background (face-foreground 'font-lock-keyword-face nil t))
      (set-face-attribute 'doom-modeline-bar-inactive nil
                          :background (face-background 'mode-line-inactive nil t))
      ;; Its bar and scroll images are cached; draw them again in the new colour.
      (doom-modeline-refresh-bars)
      (doom-modeline-invalidate-huds))
    (set-face-attribute 'mode-line-buffer-id nil
                        :foreground active-foreground :weight 'bold)))

(add-hook 'enable-theme-functions #'my-style-panes)
(my-style-panes)

;; Glass: translucent background, solid text, blurred by the compositor
;; (pgtk). In a terminal frame (emacs -nw) the terminal's own translucency
;; shows through instead.
(add-to-list 'default-frame-alist `(alpha-background . ,my-glass))

(defun my-transparent-background (&rest _)
  "Let the terminal's translucent background show through in tty frames."
  (dolist (frame (frame-list))
    (unless (display-graphic-p frame)
      (set-face-background 'default "unspecified-bg" frame))))

;; Run after the theme and pane styling have set their colors, and for each
;; new frame.
(add-hook 'enable-theme-functions #'my-transparent-background 90)
(add-hook 'after-make-frame-functions #'my-transparent-background 90)

(defun my-key-menu-style ()
  "Give the key menu a surface and accents from the active theme."
  (face-remap-add-relative 'default
                          :background (face-background 'corfu-default nil t))
  (dolist (pair '((which-key-key-face . font-lock-constant-face)
                  (which-key-group-description-face . font-lock-type-face)
                  (which-key-note-face . font-lock-constant-face)))
    (face-remap-add-relative (car pair)
                            :foreground (face-foreground (cdr pair) nil t)
                            :weight 'bold)))

;; The Space menu's popup, titled with the menu you are in.
(defun my-keypad-menu (keymap)
  "Display KEYMAP with the name of the current Space menu."
  (let* ((keys (meow--keypad-format-keys))
         (menu (if (string-empty-p keys)
                   my-leader-map
                 ;; A bare modifier prefix (SPC G is "C-M-") isn't a key yet.
                 (ignore-errors (meow--keypad-lookup-key (kbd keys)))))
         (title (and (keymapp menu) (keymap-prompt menu))))
    (which-key--create-buffer-and-show
     nil (if (string-empty-p keys) my-leader-map keymap) nil
     (concat (if (or (string-empty-p keys) meow--keypad-base-keymap)
                 (concat "SPC" (unless (string-empty-p keys) (concat " " keys)))
               keys)
             "  ·  " (or title (and (string-prefix-p "C-c" keys) "Mode") "Emacs")))))

(use-package which-key
  :demand t
  :custom
  (which-key-idle-delay 0.35)
  (which-key-idle-secondary-delay 0.05)
  (which-key-dont-use-unicode nil)
  (which-key-max-display-columns 3)
  (which-key-add-column-padding 2)
  (which-key-max-description-length 30)
  (which-key-lighter nil)
  (which-key-show-remaining-keys t)
  (which-key-separator "  ›  ")
  (which-key-prefix-prefix "")
  (which-key-ellipsis "…")
  (which-key-sort-uppercase-first nil)
  ;; The menu's title goes in the popup, above the keys.
  (which-key-show-prefix 'top)
  :bind ("C-h M-m" . which-key-show-major-mode)
  :hook (which-key-init-buffer . my-key-menu-style)
  :config
  (which-key-mode 1)
  (dolist (map '(("M-s h"     . "highlight")
                 ("M-s s"     . "symbol-overlay")
                 ("C-c &"     . "yasnippet")
                 ("C-c @"     . "hideshow")
                 ("C-c a"     . "ai")
                 ("C-c c"     . "consult")
                 ("C-c d"     . "dict")
                 ("C-c l"     . "link-hint")
                 ("C-c n"     . "org-roam")
                 ("C-c o"     . "org")
                 ("C-c t"     . "hl-todo")
                 ("C-c z"     . "kirigami")
                 ("C-c C-z"   . "browse")
                 ("C-x 8"     . "unicode")
                 ("C-x 8 e"   . "emoji")
                 ("C-x @"     . "modifior")
                 ("C-x a"     . "abbrev")
                 ("C-x c"     . "colorful")
                 ("C-x n"     . "narrow")
                 ("C-x p"     . "project")
                 ("C-x r"     . "rect & bookmark")
                 ("C-x t"     . "tab & treemacs")
                 ("C-x w"     . "window & highlight")
                 ("C-x x"     . "buffer")
                 ("C-x C-a"   . "edebug")
                 ("C-x RET"   . "coding-system")
                 ("C-x X"     . "edebug")))
    (which-key-add-key-based-replacements (car map) (cdr map)))
  ;; SPC 0 to SPC 9 (a count for the next command) take one row, not ten.
  (push '(("\\`[1-9]\\'" . "\\`meow-digit-argument\\'") . t)
        which-key-replacement-alist)
  (push '(("\\`0\\'" . "\\`meow-digit-argument\\'") . ("0…9" . "count"))
        which-key-replacement-alist))

;; Key menus, Magit's menus and the minibuffer pickers (completion.el) sit
;; in a floating box near the middle of the frame, as in Centaur.
(use-package which-key-posframe
  :commands which-key-posframe-mode
  :custom
  (which-key-posframe-border-width posframe-border-width)
  (which-key-posframe-poshandler 'posframe-poshandler-frame-center-near-bottom)
  ;; Even room on both sides: the keys column is already indented, so the
  ;; right side gets the wider fringe.
  (which-key-posframe-parameters '((left-fringe . 8)
                                   (right-fringe . 20)))
  :custom-face
  ;; The popup's own background, which shows in its fringes, is the menu's
  ;; surface colour too (my-key-menu-style); otherwise the sides are dark.
  (which-key-posframe ((t (:inherit corfu-default))))
  (which-key-posframe-border ((t (:inherit posframe-border :background unspecified))))
  :config
  ;; With the title inside the popup, which-key asks for the whole frame's
  ;; height; size the popup to its lines instead.
  (define-advice which-key-posframe--show-buffer (:filter-args (args) my-fit)
    (let ((size (car args)))
      (list (cons (min (car size)
                       (with-current-buffer which-key--buffer
                         (count-lines (point-min) (point-max))))
                  (cdr size)))))
  :hook ((emacs-startup server-after-make-frame)
         .
         (lambda ()
           (if (and which-key-mode (childframe-completion-workable-p))
               (which-key-posframe-mode 1)
             (which-key-posframe-mode -1)))))

(use-package transient-posframe
  :commands transient-posframe-mode
  :custom
  (transient-mode-line-format nil)
  (transient-posframe-border-width posframe-border-width)
  (transient-posframe-parameters '((left-fringe . 8)
                                   (right-fringe . 8)))
  (transient-posframe-poshandler #'posframe-poshandler-frame-center)
  :custom-face
  (transient-posframe-border ((t (:inherit posframe-border :background unspecified))))
  :hook ((after-init server-after-make-frame)
         .
         (lambda ()
           "Display transient in the child frame if applicable."
           (if (childframe-completion-workable-p)
               (transient-posframe-mode 1)
             (transient-posframe-mode -1)))))

(defun my-split-window (side &optional blank)
  "Focus a new pane on SIDE, optionally starting with a BLANK buffer."
  (select-window (split-window nil nil side))
  (when blank (my-new-buffer)))

(defun my-terminal ()
  "Open a project shell in the lower panel with the current environment."
  (interactive)
  (require 'eshell)
  (let* ((root (or (when-let* ((project (project-current))) (project-root project))
                   default-directory))
         (default-directory root)
         (eshell-buffer-name (format "*eshell:%s*" (abbreviate-file-name root)))
         (buffer (save-window-excursion (eshell))))
    (select-window (display-buffer buffer))))

(use-package ligature
  :demand t
  :config
  (ligature-set-ligatures 'prog-mode
    '("-->" "//" "/*" "*/" "<!--" "-->" "==" "===" "!=" "!==" "||" "&&"
      ">=" "<=" "=>" "->" "<-" "<<" ">>" "::" "++" "--" "..." ".."
      "/*" "*/" "/**" "**" "***" ";;" "!!" "??"))
  (global-ligature-mode t))

;; Flat one-pixel dividers between windows (right and bottom), a slim left
;; fringe for the git bars.
(setq window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(add-hook 'window-setup-hook #'window-divider-mode)
(window-divider-mode 1)
(set-fringe-mode '(6 . 0))

;; Line numbers in code and config files, sized to the whole file.
(use-package display-line-numbers
  :ensure nil
  :hook ((prog-mode
          conf-mode toml-ts-mode
          yaml-mode yaml-ts-mode)
         . display-line-numbers-mode)
  :init (setq display-line-numbers-width-start t))

;; Mouse & Smooth Scroll
(setq hscroll-step 1
      hscroll-margin 2
      scroll-step 1
      scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position t
      auto-window-vscroll nil
      mouse-wheel-scroll-amount-horizontal 1
      mouse-wheel-progressive-speed nil)
(use-package ultra-scroll
  :custom
  (scroll-conservatively 3)
  (scroll-margin 0)
  :hook (window-setup . ultra-scroll-mode))

;; Font size for every buffer at once: s-= / s-- / s-0.
(use-package default-text-scale
  :hook (after-init . default-text-scale-mode)
  :bind (:map default-text-scale-mode-map
         ("s-="   . default-text-scale-increase)
         ("s--"   . default-text-scale-decrease)
         ("s-0"   . default-text-scale-reset)
         ("C-s-=" . default-text-scale-increase)
         ("C-s--" . default-text-scale-decrease)
         ("C-s-0" . default-text-scale-reset)))

;; Proportional fonts for prose where wanted (centaur-read-mode uses it).
(use-package mixed-pitch :commands mixed-pitch-mode)

;; Repeatable window/buffer commands (and the Space menus that stay open,
;; see funcs.el), a match counter.
(repeat-mode 1)
(setq isearch-lazy-count t)

;;; ui.el -*- lexical-binding: t -*-

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" my-config-directory))
(load-theme 'noctalia t)
;; Mode line: doom-modeline with Centaur Emacs's choices (collapsed minor
;; modes, scroll HUD in the bar, no project name, none in terminals), a
;; taller bar in the theme's accent, and a layout with real spacing: its own
;; segments put only half a space between an icon and its text.
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
  (doom-modeline-def-segment my-gap
    "Room between segments."
    (doom-modeline-wspc))
  (doom-modeline-def-segment my-buffer
    "File-type icon, save state and name, a full space apart."
    (let ((icon (or doom-modeline--buffer-file-icon
                    (doom-modeline-update-buffer-file-icon)))
          (state doom-modeline--buffer-file-state-icon))
      (concat (doom-modeline-wspc)
              (when (and doom-modeline-icon icon (not (string-empty-p icon)))
                (concat (doom-modeline-display-icon icon) (doom-modeline-wspc)))
              (when (and doom-modeline-icon state (not (string-empty-p state)))
                (concat (doom-modeline-display-icon state) (doom-modeline-wspc)))
              (doom-modeline--buffer-name))))
  ;; Only what tells you something: state, file, position, matches; build,
  ;; language server, diagnostics, branch, and the minor-mode menu. The
  ;; file icon already shows the major mode, so its name is left out.
  (doom-modeline-def-modeline 'my-main
    '(bar my-gap modals my-buffer my-gap buffer-position my-gap matches selection-info)
    '(compilation misc-info my-gap lsp my-gap check my-gap vcs my-gap minor-modes my-gap))
  (add-hook 'doom-modeline-mode-hook
            (lambda () (doom-modeline-set-modeline 'my-main 'default)))
  (doom-modeline-mode 1))
(setq mode-line-collapse-minor-modes t)
(dolist (hook '(vterm-mode-hook eshell-mode-hook shell-mode-hook term-mode-hook))
  (add-hook hook #'mode-line-invisible-mode))

(setq display-time-default-load-average nil)

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
                          :background (face-background 'mode-line-inactive nil t)))
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
                 (meow--keypad-lookup-key (kbd keys))))
         (title (and (keymapp menu) (keymap-prompt menu))))
    (which-key--create-buffer-and-show
     nil (if (string-empty-p keys) my-leader-map keymap) nil
     (concat (if (or (string-empty-p keys) meow--keypad-base-keymap)
                 (concat "SPC" (unless (string-empty-p keys) (concat " " keys)))
               keys)
             "  ·  " (or title "Emacs")))))

(use-package which-key
  :demand t
  :custom
  (which-key-idle-delay 0.35)
  (which-key-idle-secondary-delay 0.05)
  (which-key-popup-type 'side-window)
  (which-key-side-window-location 'bottom)
  (which-key-side-window-slot 1)
  (which-key-side-window-max-height 0.4)
  (which-key-allow-imprecise-window-fit nil)
  (which-key-max-display-columns 3)
  (which-key-add-column-padding 2)
  (which-key-max-description-length 28)
  (which-key-separator "  ›  ")
  (which-key-prefix-prefix "")
  (which-key-ellipsis "…")
  (which-key-show-prefix 'mode-line)
  (which-key-sort-uppercase-first nil)
  :hook (which-key-init-buffer . my-key-menu-style)
  :config (which-key-mode 1))

(add-to-list 'display-buffer-alist
             '("\\*\\(?:eshell\\|compilation\\|Help\\|Apropos\\|Warnings\\|Flymake diagnostics\\).*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom) (slot . 0) (window-height . 0.3)))

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

;; Flat one-pixel dividers between windows, a slim left fringe for the git
;; bars, the current line highlighted in code, steady line-number width.
(setq window-divider-default-places 'right-only
      window-divider-default-right-width 1)
(window-divider-mode 1)
(set-fringe-mode '(6 . 0))
(setq-default display-line-numbers-width 3)
(add-hook 'prog-mode-hook #'hl-line-mode)

;; Smooth scrolling, repeatable window/buffer commands, a match counter.
(pixel-scroll-precision-mode 1)
(repeat-mode 1)
(setq isearch-lazy-count t)

;; Richer help pages (source, references, keybindings) for the usual C-h keys.
(use-package helpful
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key] . helpful-key)
         ([remap describe-command] . helpful-command)
         ([remap describe-symbol] . helpful-symbol)))

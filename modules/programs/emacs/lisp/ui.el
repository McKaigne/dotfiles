;;; ui.el -*- lexical-binding: t -*-

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" lysec-config-directory))
(load-theme 'noctalia t)
;; Mode line: state, a status dot, the file-type icon and buffer, position;
;; the git branch and the checker's summary on the right, with nerd-icons.
;; Every colour is a theme face (or the icon's own), so it follows Noctalia.
(require 'nerd-icons)
(defun lysec-mode-line-dot ()
  "A dot: dim when saved, error-coloured when modified, warning when read-only."
  (cond (buffer-read-only (propertize "●" 'face 'warning 'help-echo "Read-only"))
        ((and buffer-file-name (buffer-modified-p))
         (propertize "●" 'face 'error 'help-echo "Modified"))
        (t (propertize "●" 'face 'shadow 'help-echo "Saved"))))

(defun lysec-mode-line-icon ()
  "The file type's icon (nerd-icons, in its own colour)."
  (let ((icon (nerd-icons-icon-for-buffer)))
    (when (and (stringp icon) (not (string-empty-p icon)))
      (concat icon " "))))

(defun lysec-mode-line-branch ()
  "The current git branch, if any."
  (when (and vc-mode buffer-file-name)
    (concat (nerd-icons-octicon "nf-oct-git_branch" :face 'shadow) " "
            (replace-regexp-in-string "\\`[ ]*[A-Za-z]+[-:@!?]" ""
                                      (substring-no-properties vc-mode)))))

(defun lysec-mode-line-issues ()
  "Flymake's error and warning counts, or a quiet all-clear."
  (when (bound-and-true-p flymake-mode)
    (let ((errors 0) (warnings 0))
      (dolist (diagnostic (flymake-diagnostics))
        (pcase (flymake--lookup-type-property
                (flymake-diagnostic-type diagnostic) 'flymake-category)
          ('flymake-error (cl-incf errors))
          ('flymake-warning (cl-incf warnings))))
      (if (= 0 errors warnings)
          (concat (nerd-icons-codicon "nf-cod-pass" :face 'success) " "
                  (propertize "No issues" 'face 'shadow))
        (string-join
         (delq nil (list (when (> errors 0)
                           (concat (nerd-icons-codicon "nf-cod-error" :face 'error) " "
                                   (propertize (number-to-string errors) 'face 'error)))
                         (when (> warnings 0)
                           (concat (nerd-icons-codicon "nf-cod-warning" :face 'warning) " "
                                   (propertize (number-to-string warnings) 'face 'warning)))))
         "  ")))))

(setq-default mode-line-format
              '("%e" "  " (:eval (meow-indicator)) " " (:eval (lysec-mode-line-dot)) " "
                (:eval (lysec-mode-line-icon))
                mode-line-buffer-identification "   %l:%c  "
                (:propertize "%p" face shadow)
                mode-line-format-right-align
                (:eval (lysec-mode-line-branch)) "    "
                (:eval (lysec-mode-line-issues)) "  "))
(setq display-time-default-load-average nil)

(require 'disp-table)
(unless standard-display-table
  (setq standard-display-table (make-display-table)))
(set-display-table-slot standard-display-table 'vertical-border
                        (make-glyph-code ?│ 'vertical-border))

(defun lysec-style-panes (&rest _)
  "Keep pane boundaries visible using colors from the active theme."
  (let ((border (face-foreground 'shadow nil t))
        (active-background (face-background 'mode-line nil t))
        (active-foreground (face-foreground 'mode-line nil t))
        (inactive-background (face-background 'corfu-default nil t)))
    (set-face-attribute 'vertical-border nil
                        :foreground border
                        :background (face-background 'default nil t))
    ;; The box is drawn in the bar's own colour: it reads as padding.
    (set-face-attribute 'mode-line-active nil
                        :background active-background
                        :foreground active-foreground
                        :box (list :line-width '(1 . 7) :color active-background))
    (set-face-attribute 'mode-line-inactive nil
                        :background inactive-background
                        :box (list :line-width '(1 . 7) :color inactive-background))
    (dolist (face '(window-divider window-divider-first-pixel window-divider-last-pixel))
      (set-face-attribute face nil :foreground border))
    (set-face-attribute 'mode-line-buffer-id nil
                        :foreground active-foreground :weight 'bold)))

(add-hook 'enable-theme-functions #'lysec-style-panes)
(lysec-style-panes)

;; Glass: translucent background, solid text, blurred by the compositor
;; (pgtk). In a terminal frame (emacs -nw) the terminal's own translucency
;; shows through instead.
(add-to-list 'default-frame-alist `(alpha-background . ,lysec-glass))

(defun lysec-transparent-background (&rest _)
  "Let the terminal's translucent background show through in tty frames."
  (dolist (frame (frame-list))
    (unless (display-graphic-p frame)
      (set-face-background 'default "unspecified-bg" frame))))

;; Run after the theme and pane styling have set their colors, and for each
;; new frame.
(add-hook 'enable-theme-functions #'lysec-transparent-background 90)
(add-hook 'after-make-frame-functions #'lysec-transparent-background 90)

(defun lysec-key-menu-style ()
  "Give the key menu a surface and accents from the active theme."
  (face-remap-add-relative 'default
                          :background (face-background 'corfu-default nil t))
  (dolist (pair '((which-key-key-face . font-lock-constant-face)
                  (which-key-group-description-face . font-lock-type-face)
                  (which-key-note-face . font-lock-constant-face)))
    (face-remap-add-relative (car pair)
                            :foreground (face-foreground (cdr pair) nil t)
                            :weight 'bold)))

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
  :hook (which-key-init-buffer . lysec-key-menu-style)
  :config (which-key-mode 1))

(add-to-list 'display-buffer-alist
             '("\\*\\(?:eshell\\|compilation\\|Help\\|Apropos\\|Warnings\\|Flymake diagnostics\\).*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom) (slot . 0) (window-height . 0.3)))

(defun lysec-split-window (side &optional blank)
  "Focus a new pane on SIDE, optionally starting with a BLANK buffer."
  (select-window (split-window nil nil side))
  (when blank (lysec-new-buffer)))

(defun lysec-terminal ()
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

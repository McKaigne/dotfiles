;;; ui.el -*- lexical-binding: t -*-

(add-to-list 'custom-theme-load-path (expand-file-name "themes" nixmacs-config-directory))
(add-to-list 'default-frame-alist `(alpha-background . ,nixmacs-glass))
(set-fringe-mode '(6 . 0))

(use-package nerd-icons
  :demand t)

(defvar nixmacs-flat-faces
  '(mode-line mode-line-active mode-line-inactive header-line header-line-inactive
    tab-bar tab-bar-tab tab-bar-tab-inactive tab-line tab-line-tab
    tab-line-tab-active tab-line-tab-inactive tab-line-tab-current))

(defun nixmacs-flatten-frame (&rest _)
  "Give bars, fringes and dividers the theme's background, with no borders."
  (when-let* ((background (face-background 'default nil t))
              ((string-match-p "\\`#[[:xdigit:]]\\{6\\}\\'" background)))
    (dolist (face nixmacs-flat-faces)
      (when (facep face)
        (set-face-attribute face nil :background background :box nil
                            :overline nil :underline nil)))
    (dolist (face '(mode-line-highlight header-line-highlight))
      (when (facep face)
        (set-face-attribute face nil :box nil)))
    (dolist (face '(fringe internal-border))
      (set-face-attribute face nil :background background))
    (dolist (face '(vertical-border window-divider window-divider-first-pixel
                    window-divider-last-pixel))
      (set-face-attribute face nil :foreground background :background background))
    (set-face-attribute 'mode-line-buffer-id nil
                        :foreground (or (face-foreground 'mode-line nil t) 'unspecified)
                        :weight 'bold)
    (when (facep 'doom-modeline-bar)
      (set-face-attribute 'doom-modeline-bar nil
                          :background (or (face-background 'cursor nil t)
                                          (face-foreground 'font-lock-keyword-face nil t)))
      (set-face-attribute 'doom-modeline-bar-inactive nil :background background)
      (doom-modeline-refresh-bars))))

(add-hook 'enable-theme-functions #'nixmacs-flatten-frame 85)

(use-package spacious-padding
  :demand t
  :custom
  (spacious-padding-widths '(:internal-border-width 12 :header-line-width 0
                             :mode-line-width 0 :tab-width 0
                             :right-divider-width 1 :scroll-bar-width 0
                             :fringe-width 6))
  :config
  (spacious-padding-mode 1))

(use-package doom-modeline
  :demand t
  :custom
  (doom-modeline-height 28)
  (doom-modeline-bar-width 4)
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-minor-modes nil)
  (doom-modeline-modal-icon t)
  :config
  (defun nixmacs-modeline-icon (icon)
    "Return ICON followed by a gap, or nothing when ICON is empty."
    (when (and icon (not (string-empty-p icon)))
      (concat icon (propertize " " 'face (doom-modeline-spc-face)
                               'display '(space :width 1.5)))))
  (doom-modeline-def-segment buffer-info
    "The buffer's icon, state and name."
    (concat
     (doom-modeline-spc)
     (when (and doom-modeline-icon doom-modeline-major-mode-icon)
       (when-let* ((icon (or doom-modeline--buffer-file-icon
                             (doom-modeline-update-buffer-file-icon))))
         (nixmacs-modeline-icon
          (if doom-modeline-major-mode-color-icon
              (doom-modeline-display-icon icon)
            (doom-modeline-propertize-icon icon (doom-modeline-face))))))
     (when (and doom-modeline-icon doom-modeline-buffer-state-icon
                doom-modeline--buffer-file-state-icon)
       (nixmacs-modeline-icon
        (doom-modeline-display-icon doom-modeline--buffer-file-state-icon)))
     (doom-modeline--buffer-name)))
  (defun nixmacs-modeline-directory (face &optional state)
    "Return the folder icon and `default-directory' in FACE, with STATE icon."
    (concat
     (doom-modeline-spc)
     (and doom-modeline-major-mode-icon
          (nixmacs-modeline-icon
           (doom-modeline-icon 'octicon "nf-oct-file_directory_fill" "🖿" ""
                               :face face)))
     (and state doom-modeline-icon doom-modeline-buffer-state-icon
          doom-modeline--buffer-file-state-icon
          (nixmacs-modeline-icon
           (doom-modeline-display-icon doom-modeline--buffer-file-state-icon)))
     (propertize (abbreviate-file-name default-directory) 'face face)))
  (doom-modeline-def-segment buffer-default-directory
    "The folder icon and `default-directory'."
    (nixmacs-modeline-directory
     (doom-modeline-face (if (and buffer-file-name (buffer-modified-p))
                             'doom-modeline-buffer-modified
                           'doom-modeline-buffer-path))
     t))
  (doom-modeline-def-segment buffer-default-directory-simple
    "The folder icon and `default-directory', without state."
    (nixmacs-modeline-directory (doom-modeline-face 'doom-modeline-buffer-path)))
  (doom-modeline-mode 1))

(load-theme 'noctalia t)

(defun nixmacs-transparent-background (&rest _)
  "Let a terminal's own translucency show through in text frames."
  (dolist (frame (frame-list))
    (unless (display-graphic-p frame)
      (set-face-background 'default "unspecified-bg" frame))))

(add-hook 'enable-theme-functions #'nixmacs-transparent-background 90)
(add-hook 'after-make-frame-functions #'nixmacs-transparent-background 90)

(with-eval-after-load 'posframe
  (define-advice posframe--create-posframe (:after (&rest _) solid)
    (set-frame-parameter posframe--frame 'alpha-background 100)))

(defun nixmacs-delete-focused-child-frame (hide &optional frame &rest args)
  "Call HIDE on FRAME with ARGS, or delete FRAME when it is a focused child."
  (let ((frame (or frame (selected-frame))))
    (if-let* (((frame-live-p frame))
              (parent (frame-parent frame))
              ((or (eq frame (selected-frame))
                   (eq (frame-focus-state frame) t))))
        (let ((selected (eq frame (selected-frame)))
              (global-hooks (default-value 'delete-frame-functions)))
          (save-current-buffer
            (unwind-protect
                (progn
                  (set-default 'delete-frame-functions nil)
                  (delete-frame frame))
              (set-default 'delete-frame-functions global-hooks))
            (when (and selected (frame-live-p parent))
              (select-frame parent))))
      (apply hide frame args))))
(advice-add 'make-frame-invisible :around #'nixmacs-delete-focused-child-frame)

(defface nixmacs-label
  '((t :height 0.8 :width condensed :weight semibold :slant normal
       :inverse-video t))
  "Base face for keyword labels, drawn like Org's todo labels.")

(defface nixmacs-label-todo
  '((t :inherit (font-lock-function-name-face nixmacs-label)))
  "Label for work still to do.")

(defface nixmacs-label-next
  '((t :inherit (font-lock-string-face nixmacs-label)))
  "Label for work in progress.")

(defface nixmacs-label-wait
  '((t :inherit (font-lock-keyword-face nixmacs-label)))
  "Label for work on hold.")

(defface nixmacs-label-fix
  '((t :inherit (error nixmacs-label)))
  "Label for something broken.")

(defface nixmacs-label-hack
  '((t :inherit (warning nixmacs-label)))
  "Label for a workaround.")

(defface nixmacs-label-note
  '((t :inherit (shadow nixmacs-label)))
  "Label for a remark or finished work.")

(use-package hl-todo
  :demand t
  :custom
  (hl-todo-keyword-faces
   '(("TODO" . nixmacs-label-todo)
     ("NEXT" . nixmacs-label-next)
     ("PROG" . nixmacs-label-next)
     ("WIP" . nixmacs-label-next)
     ("HOLD" . nixmacs-label-wait)
     ("WAIT" . nixmacs-label-wait)
     ("MAYBE" . nixmacs-label-wait)
     ("TEMP" . nixmacs-label-wait)
     ("FIXME" . nixmacs-label-fix)
     ("BUG" . nixmacs-label-fix)
     ("FAIL" . nixmacs-label-fix)
     ("DEBUG" . nixmacs-label-fix)
     ("DONT" . nixmacs-label-fix)
     ("XXXX*" . nixmacs-label-fix)
     ("HACK" . nixmacs-label-hack)
     ("KLUDGE" . nixmacs-label-hack)
     ("NOTE" . nixmacs-label-note)
     ("OKAY" . nixmacs-label-note)
     ("DONE" . nixmacs-label-note)))
  :config
  (global-hl-todo-mode 1))

(unless standard-display-table
  (setq standard-display-table (make-display-table)))
(set-display-table-slot standard-display-table 'selective-display
                        (vconcat (mapcar (lambda (char) (make-glyph-code char 'shadow))
                                         " …")))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package indent-bars
  :hook (prog-mode . indent-bars-mode)
  :custom
  (indent-bars-treesit-support t)
  (indent-bars-no-descend-string t)
  (indent-bars-display-on-blank-lines nil)
  (indent-bars-width-frac 0.15)
  (indent-bars-color '(shadow :face-bg nil :blend 0.4))
  (indent-bars-highlight-current-depth '(:face font-lock-function-name-face :blend 0.45)))

(use-package breadcrumb
  :hook (prog-mode . breadcrumb-local-mode))

(use-package pulsar
  :demand t
  :custom
  (pulsar-pulse t)
  (pulsar-delay 0.04)
  (pulsar-iterations 8)
  (pulsar-face 'pulsar-magenta)
  :config
  (dolist (command '(ace-window avy-goto-char-timer avy-goto-line
                     windmove-left windmove-right windmove-up windmove-down
                     nixmacs-select-next-pane nixmacs-select-previous-pane
                     xref-find-definitions xref-go-back consult-line
                     consult-imenu consult-ripgrep))
    (add-to-list 'pulsar-pulse-functions command))
  (pulsar-global-mode 1))

(use-package ligature
  :demand t
  :config
  (ligature-set-ligatures
   'prog-mode
   '("<--" "<---" "<<-" "<-" "->" "-->" "--->" "->>" "-<" ">-" "-<<" ">>-"
     "<==" "<===" "<<=" "<=" "=>" "==>" "===>" "=>>" "=<" ">=" "=<<" ">>="
     "<=>" "<==>" "<->" "<-->" "==" "===" "!=" "!==" "=/=" "=!=" "::" ":::"
     ":=" "=:" ":>" "<:" "..." ".." "..<" ".=" "&&" "||" "|>" "<|" "<|>"
     "||>" "<||" "//" "///" "/*" "*/" "/**" "++" "+++" "--" "---" "<>" "</"
     "/>" "</>" "<<" ">>" "<<<" ">>>" "##" "###" "####" "#{" "#[" "#(" "#?"
     "#!" "#:" "#=" "#_" "#_(" "{{" "}}" "[|" "|]" ";;" "~~" "~>" "<~" "~-"
     "-~" "??" "?." "?:" "!!" "%%" "__" "_|_" "|-" "-|" "\\\\" "0x"))
  (global-ligature-mode 1))

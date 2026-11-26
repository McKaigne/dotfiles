;;; ui.el -*- lexical-binding: t -*-

(add-to-list 'custom-theme-load-path (expand-file-name "themes" my-config-directory))
(add-to-list 'default-frame-alist `(alpha-background . ,my-glass))
(set-fringe-mode '(6 . 0))

(use-package nerd-icons
  :demand t)

(defvar my-flat-faces
  '(mode-line mode-line-active mode-line-inactive header-line header-line-inactive
    tab-bar tab-bar-tab tab-bar-tab-inactive tab-line tab-line-tab
    tab-line-tab-active tab-line-tab-inactive tab-line-tab-current))

(defun my-flatten-frame (&rest _)
  "Give bars, fringes and dividers the theme's background, with no borders."
  (when-let* ((background (face-background 'default nil t))
              ((string-match-p "\\`#[[:xdigit:]]\\{6\\}\\'" background)))
    (dolist (face my-flat-faces)
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

(add-hook 'enable-theme-functions #'my-flatten-frame 85)

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
  (defun my-modeline-icon (icon)
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
    "Return the folder icon and `default-directory' in FACE, with STATE icon."
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
    "The folder icon and `default-directory'."
    (my-modeline-directory
     (doom-modeline-face (if (and buffer-file-name (buffer-modified-p))
                             'doom-modeline-buffer-modified
                           'doom-modeline-buffer-path))
     t))
  (doom-modeline-def-segment buffer-default-directory-simple
    "The folder icon and `default-directory', without state."
    (my-modeline-directory (doom-modeline-face 'doom-modeline-buffer-path)))
  (doom-modeline-mode 1))

(load-theme 'noctalia t)

(defun my-transparent-background (&rest _)
  "Let a terminal's own translucency show through in text frames."
  (dolist (frame (frame-list))
    (unless (display-graphic-p frame)
      (set-face-background 'default "unspecified-bg" frame))))

(add-hook 'enable-theme-functions #'my-transparent-background 90)
(add-hook 'after-make-frame-functions #'my-transparent-background 90)

(with-eval-after-load 'posframe
  (define-advice posframe--create-posframe (:after (&rest _) solid)
    (set-frame-parameter posframe--frame 'alpha-background 100)))

(use-package knockknock
  :demand t
  :custom
  (knockknock-poshandler #'posframe-poshandler-frame-top-right-corner)
  (knockknock-use-svg-layout t)
  (knockknock-border-width 0)
  (knockknock-lighten-background-percent 6)
  (knockknock-default-duration 3))

(defun my-notify (title message icon &optional duration)
  "Show a notification with TITLE, MESSAGE and ICON for DURATION seconds."
  (knockknock-notify :title title :message message :icon icon
                     :duration (or duration knockknock-default-duration)))

(defun my-notify-compile (buffer status)
  "Report how the compilation in BUFFER ended, from STATUS."
  (let ((name (buffer-name buffer))
        (status (string-trim status)))
    (if (string-prefix-p "finished" status)
        (my-notify "Compilation finished" name "nf-cod-check")
      (my-notify "Compilation failed" (format "%s: %s" name status)
                 "nf-cod-error" 5))))

(add-hook 'compilation-finish-functions #'my-notify-compile)

(defun my-notify-save ()
  "Report that this buffer was saved."
  (my-notify "Saved" (buffer-name) "nf-fa-save"))

(setq save-silently t)
(add-hook 'after-save-hook #'my-notify-save)

(defun my-notify-magit (arg &rest _)
  "Report how the git push, pull or fetch process ARG ended."
  (when-let* (((processp arg))
              (command (seq-find (lambda (word) (member word '("push" "pull" "fetch")))
                                 (process-command arg))))
    (if (zerop (process-exit-status arg))
        (my-notify (format "Git %s finished" command)
                   (abbreviate-file-name (or (process-get arg 'default-dir) ""))
                   "nf-dev-git")
      (my-notify (format "Git %s failed" command)
                 "See the process buffer ($) for details" "nf-dev-git" 5))))

(with-eval-after-load 'magit-process
  (advice-add 'magit-process-finish :before #'my-notify-magit))

(defun my-notify-eglot (server)
  "Report that SERVER is connected."
  (my-notify (format "%s ready" (or (plist-get (eglot--server-info server) :name)
                                    "Language server"))
             (eglot-project-nickname server) "nf-cod-server"))

(add-hook 'eglot-connect-hook #'my-notify-eglot)

(defun my-notify-formatter (&rest args)
  "Report a formatter failure described by ARGS."
  (when (plist-get args :error)
    (my-notify "Formatting failed"
               (format "%s on %s" (plist-get args :formatter) (buffer-name))
               "nf-cod-warning" 5)))

(add-hook 'apheleia-formatter-exited-hook #'my-notify-formatter)

(defun my-notify-timer ()
  "Report that the Org timer is done."
  (my-notify "Timer done" "The Org countdown has finished" "nf-md-timer" 5))

(defun my-notify-clock-in ()
  "Report the task just clocked in."
  (my-notify "Clocked in" org-clock-heading "nf-md-clock"))

(defun my-notify-clock-out ()
  "Report the task just clocked out and the time it took."
  (my-notify "Clocked out"
             (format "%s (%s)" org-clock-heading
                     (org-duration-from-minutes
                      (floor (float-time (time-subtract org-clock-out-time
                                                        org-clock-start-time))
                             60)))
             "nf-md-clock"))

(add-hook 'org-timer-done-hook #'my-notify-timer)
(add-hook 'org-clock-in-hook #'my-notify-clock-in)
(add-hook 'org-clock-out-hook #'my-notify-clock-out)

(defun my-delete-focused-child-frame (hide &optional frame &rest args)
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
(advice-add 'make-frame-invisible :around #'my-delete-focused-child-frame)

(use-package hl-todo
  :demand t
  :config
  (global-hl-todo-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package indent-bars
  :hook (prog-mode . indent-bars-mode)
  :custom
  (indent-bars-treesit-support t)
  (indent-bars-no-descend-string t)
  (indent-bars-width-frac 0.15)
  (indent-bars-color '(highlight :face-bg t :blend 0.3))
  (indent-bars-highlight-current-depth '(:blend 0.6)))

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
                     xref-find-definitions xref-go-back consult-line
                     consult-imenu consult-ripgrep))
    (add-to-list 'pulsar-pulse-functions command))
  (pulsar-global-mode 1))

(defun my-zoom-ignore-p ()
  "Leave side windows and dedicated windows at their own size."
  (or (window-parameter nil 'window-side)
      (window-dedicated-p)))

(use-package zoom
  :demand t
  :custom
  (zoom-size '(0.618 . 0.618))
  (zoom-ignore-predicates '(my-zoom-ignore-p))
  (zoom-ignored-buffer-name-regexps '("\\`\\*which-key\\*" "\\`\\*transient\\*"))
  :config
  (zoom-mode 1))

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

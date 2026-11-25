;;; tools.el -*- lexical-binding: t -*-

(setq ghostel-module-directory my-ghostel-module-directory
      ghostel-module-auto-install nil)

(use-package ghostel
  :commands (ghostel ghostel-project ghostel-create)
  :custom
  (ghostel-keymap-exceptions
   '("C-c" "C-x" "C-u" "C-h" "M-x" "M-:" "C-\\"
     "C-." "M-SPC" "M-h" "M-j" "M-k" "M-l"))
  :config
  (keymap-set ghostel-mode-map "M-SPC" #'meow-keypad)
  (add-hook 'ghostel-exit-functions #'my-terminal-popup-exit))

(defvar-local my-terminal-popup nil)
(defvar-local my-terminal-popup-origin nil)

(defvar my-terminal-popup-action
  '((display-buffer-reuse-window display-buffer-in-side-window)
    (side . bottom) (slot . 0) (window-height . 0.3)
    (preserve-size . (nil . t))))

(defun my-terminal-root ()
  "Return the project root, or `default-directory' outside a project."
  (if-let* ((project (project-current))) (project-root project) default-directory))

(defun my-terminal-popup-name ()
  "Return the popup terminal's buffer name for the current project."
  (format "*ghostel-popup: %s*"
          (if-let* ((project (project-current))) (project-name project) "main")))

(defun my-terminal-popup-windows ()
  "Return the windows of this frame showing a popup terminal."
  (seq-filter (lambda (window)
                (buffer-local-value 'my-terminal-popup (window-buffer window)))
              (window-list nil 'nomini)))

(defun my-terminal-enter-insert ()
  "Put the selected terminal in insert state."
  (when (and (bound-and-true-p meow-mode) (not (meow-insert-mode-p)))
    (meow--switch-state 'insert)))

(defun my-terminal-return-to (window)
  "Select WINDOW if it still exists, else any ordinary window."
  (select-window
   (if (window-live-p window)
       window
     (or (get-mru-window nil nil t) (frame-first-window)))))

(defun my-terminal-popup-close ()
  "Hide every popup terminal in this frame and return to where it was opened."
  (let (origin)
    (dolist (window (my-terminal-popup-windows))
      (setq origin (or origin (buffer-local-value 'my-terminal-popup-origin
                                                  (window-buffer window))))
      (when (window-live-p window)
        (delete-window window)))
    (my-terminal-return-to origin)))

(defun my-terminal-popup-exit (buffer _event)
  "Return focus to the popup's origin when its shell in BUFFER exits."
  (when (buffer-local-value 'my-terminal-popup buffer)
    (let ((origin (buffer-local-value 'my-terminal-popup-origin buffer)))
      (run-at-time 0 nil #'my-terminal-return-to origin))))

(defun my-terminal-toggle (&optional recreate)
  "Toggle a terminal popup in the project root.
With RECREATE, start a fresh terminal in place of the old one."
  (interactive "P")
  (if (and (my-terminal-popup-windows) (not recreate))
      (my-terminal-popup-close)
    (when (my-terminal-popup-windows)
      (my-terminal-popup-close))
    (let* ((origin (selected-window))
           (name (my-terminal-popup-name))
           (buffer (get-buffer name)))
      (when (and recreate (buffer-live-p buffer))
        (let ((kill-buffer-query-functions nil))
          (kill-buffer buffer))
        (setq buffer nil))
      (unless (buffer-live-p buffer)
        (let ((default-directory (my-terminal-root)))
          (setq buffer (ghostel-create name my-terminal-popup-action)))
        (with-current-buffer buffer
          (setq my-terminal-popup t)))
      (with-current-buffer buffer
        (setq my-terminal-popup-origin origin))
      (select-window (or (get-buffer-window buffer)
                         (display-buffer buffer my-terminal-popup-action)))
      (my-terminal-enter-insert))))

(defun my-terminal-here (&optional here)
  "Open a terminal in this window, in the project root.
With HERE, open it in `default-directory' instead."
  (interactive "P")
  (if (or here (not (project-current)))
      (ghostel)
    (ghostel-project))
  (my-terminal-enter-insert))

(use-package dirvish
  :demand t
  :custom
  (dirvish-attributes '(nerd-icons subtree-state vc-state file-size))
  (dirvish-side-width 32)
  (dired-listing-switches "-l --almost-all --human-readable --group-directories-first --no-group")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  :config
  (require 'dirvish-side)
  (require 'dirvish-subtree)
  (dirvish-override-dired-mode 1)
  (dirvish-side-follow-mode 1))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-key helpful-command
             helpful-at-point))

(defvar-local my-markdown-preview-source nil)

(defun my-markdown-render-code (dom)
  "Render DOM as inline code."
  (shr-fontize-dom dom 'org-code))

(defun my-markdown-render-code-block (dom)
  "Render DOM as a code block, keeping its whitespace."
  (let ((start (point)))
    (shr-tag-pre dom)
    (shr-add-font start (point) 'org-block)))

(defun my-markdown-preview ()
  "Render Markdown in a reading pane, or refresh its preview."
  (interactive)
  (require 'eww)
  (require 'markdown-mode)
  (let* ((source (or my-markdown-preview-source (current-buffer)))
         (html (generate-new-buffer " *Markdown HTML*"))
         preview)
    (unwind-protect
        (with-current-buffer source
          (unless (derived-mode-p 'markdown-mode 'markdown-ts-mode)
            (user-error "Open a Markdown buffer first"))
          (let* ((name (buffer-name))
                 (directory default-directory)
                 (url (url-encode-url (concat "file://" (or buffer-file-name directory))))
                 (text (save-restriction (widen) (buffer-string))))
            (with-temp-buffer
              (insert text)
              (delay-mode-hooks (markdown-mode))
              (let ((mark-active nil))
                (markdown-standalone (buffer-name html) name)))
            (setq preview (get-buffer-create (format "*Markdown: %s*" name)))
            (with-current-buffer preview
              (eww-mode)
              (setq-local my-markdown-preview-source source
                          default-directory directory
                          shr-use-fonts nil
                          shr-use-colors nil
                          shr-inhibit-images t
                          shr-table-horizontal-line ?─
                          shr-table-vertical-line ?│
                          shr-table-corner ?┼
                          shr-external-rendering-functions
                          '((code . my-markdown-render-code)
                            (pre . my-markdown-render-code-block))
                          eww-data (list :url url))
              (dotimes (index 6)
                (face-remap-add-relative
                 (intern (format "shr-h%d" (1+ index)))
                 :inherit (intern (format "org-level-%d" (1+ index)))
                 :height 1.0 :weight 'bold :slant 'normal))
              (let ((map (copy-keymap eww-mode-map)))
                (keymap-set map "g" #'my-markdown-preview)
                (use-local-map map)))
            (pop-to-buffer preview
                           '((display-buffer-reuse-window display-buffer-in-side-window)
                             (side . right) (slot . 0) (window-width . 0.5)))
            (with-current-buffer html
              (goto-char (point-min))
              (eww-display-html 'utf-8 url nil nil preview))
            (with-current-buffer preview (set-buffer-modified-p nil))))
      (kill-buffer html))
    (set-buffer preview)))

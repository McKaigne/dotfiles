;;; dashboard.el -*- lexical-binding: t -*-

(require 'button)

(defface my-dashboard-title '((t (:inherit font-lock-function-name-face :weight bold)))
  "Dashboard title.")
(defface my-dashboard-stars '((t (:inherit font-lock-type-face))) "Dashboard star map.")
(defface my-dashboard-accent '((t (:inherit font-lock-constant-face)))
  "Dashboard action keys.")
(defface my-dashboard-button '((t (:inherit default))) "Dashboard actions.")

(defun my-new-file ()
  "Choose a path for a new file."
  (interactive)
  (find-file (read-file-name "New file: " default-directory nil nil)))

(defvar my-dashboard-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (dolist (entry '(("n" . my-new-file)
                     ("r" . consult-recent-file)
                     ("p" . my-project-open)
                     ("o" . my-org-open)
                     ("j" . my-org-journal)
                     ("a" . org-agenda)
                     ("g" . magit-status)
                     ("TAB" . forward-button)
                     ("<backtab>" . backward-button)))
      (define-key map (kbd (car entry)) (cdr entry)))
    map))

(define-derived-mode my-dashboard-mode special-mode "Observatory"
  "A keyboard-driven starting point for projects and notes."
  (setq-local cursor-type nil
              truncate-lines t
              mode-line-format nil))

(defun my-dashboard-line (text &optional face)
  "Insert centered TEXT with FACE in the dashboard."
  (let ((padding (max 2 (/ (- (window-body-width) (string-width text)) 2))))
    (insert (make-string padding ?\s)
            (propertize text 'face (or face 'default)) "\n")))

(defun my-dashboard-action (key label command)
  "Insert a dashboard action with KEY, LABEL, and COMMAND."
  (let* ((text (format "[%s]  %-21s" key label))
         (padding (max 2 (/ (- (window-body-width) (string-width text)) 2))))
    (insert (make-string padding ?\s))
    (insert (propertize (format "[%s]  " key) 'face 'my-dashboard-accent))
    (insert-text-button label 'face 'my-dashboard-button 'follow-link t
                        'help-echo (format "Press %s or RET" key)
                        'action (lambda (_) (call-interactively command)))
    (insert "\n")))

(defun my-dashboard-render ()
  "Render the observatory at the current window width."
  (let ((inhibit-read-only t))
    (erase-buffer)
    (insert "\n\n")
    ;; The picture is centred as one block: lines have different lengths,
    ;; so centring each on its own would shear it.
    (let* ((art '("·                 ✦            ·"
                  "       .         / \\          "
                  "  ✧             /   \\     .   "
                  "          ·    /  ◇  \\        "
                  "              /_______\\       "
                  "    ·           / | \\       ✧ "
                  "          .    /  |  \\        "))
           (width (apply #'max (mapcar #'string-width art)))
           (padding (max 2 (/ (- (window-body-width) width) 2))))
      (dolist (line art)
        (insert (make-string padding ?\s)
                (propertize line 'face 'my-dashboard-stars) "\n")))
    (insert "\n")
    (my-dashboard-line "O B S E R V A T O R Y" 'my-dashboard-title)
    (my-dashboard-line "a quiet place to make things" 'font-lock-comment-face)
    (insert "\n")
    (dolist (entry '(("p" "Projects" my-project-open)
                     ("n" "New file" my-new-file)
                     ("r" "Recent files" consult-recent-file)
                     ("o" "Notes" my-org-open)
                     ("j" "Today's journal" my-org-journal)
                     ("a" "Agenda" org-agenda)
                     ("g" "Git status" magit-status)))
      (apply #'my-dashboard-action entry))
    (insert "\n")
    (my-dashboard-line (format-time-string "%A, %d %B") 'font-lock-comment-face)
    (my-dashboard-line "SPC k: key guide    SPC ?: meow cheatsheet    TAB / RET: choose" 'font-lock-comment-face)
    (goto-char (point-min))))

(defun my-dashboard-buffer ()
  "Return the refreshed dashboard buffer."
  (let ((buffer (get-buffer-create "*Observatory*")))
    (with-current-buffer buffer
      (my-dashboard-mode)
      (my-dashboard-render))
    buffer))

(defun my-dashboard-open ()
  "Open the dashboard in the current window."
  (interactive)
  (switch-to-buffer (my-dashboard-buffer))
  (my-dashboard-render))

(defun my-dashboard-resize (frame)
  "Redraw dashboard windows on FRAME after resizing."
  (dolist (window (window-list frame 'no-minibuffer))
    (with-selected-window window
      (when (derived-mode-p 'my-dashboard-mode)
        (my-dashboard-render)))))

(setq initial-buffer-choice #'my-dashboard-buffer)
(add-hook 'window-size-change-functions #'my-dashboard-resize)
;; Daemon frames: initial-buffer-choice renders before the frame exists, at
;; the daemon's placeholder width; redraw once the real frame is up.
(add-hook 'server-after-make-frame-hook
          (lambda () (my-dashboard-resize (selected-frame))))

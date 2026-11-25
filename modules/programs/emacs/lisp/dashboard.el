;;; dashboard.el -*- lexical-binding: t -*-

(defvar my-homepage "https://github.com/McKaigne/dotfiles")
(defvar my-dashboard-recover-layout nil)

(defun my-browse-homepage ()
  "Visit the dotfiles repository."
  (interactive)
  (browse-url my-homepage))

(defun my-restore-session ()
  "Restore the last saved desktop session."
  (interactive)
  (my-quit-dashboard)
  (desktop-read))

(defun my-open-settings ()
  "Open this Emacs config's source in the system flake."
  (interactive)
  (my-quit-dashboard)
  (dired my-config-source))

(defun my-update-system ()
  "Rebuild and switch the system in a terminal."
  (interactive)
  (ghostel)
  (ghostel-send-string "git -C /etc/nixos add -A && nh os switch\n"))

(defun my-open-keybindings ()
  "Open the key reference in a pane on the right."
  (interactive)
  (unless (file-readable-p my-keybindings-file)
    (user-error "Key reference is missing: %s" my-keybindings-file))
  (select-window (split-window-right))
  (find-file-read-only my-keybindings-file)
  (goto-char (point-min)))

(defun my-open-dashboard ()
  "Show the dashboard in a single window."
  (interactive)
  (when (length> (window-list-1) 1)
    (setq my-dashboard-recover-layout t)
    (delete-other-windows))
  (dashboard-open))

(defun my-quit-dashboard ()
  "Close the dashboard and bring back the previous layout."
  (interactive)
  (quit-window t)
  (when my-dashboard-recover-layout
    (winner-undo)
    (setq my-dashboard-recover-layout nil)))

(use-package dashboard
  :demand t
  :custom-face
  (dashboard-heading ((t (:inherit (font-lock-string-face bold)))))
  (dashboard-items-face ((t (:weight normal))))
  (dashboard-no-items-face ((t (:weight normal))))
  :bind (("<f2>" . my-open-dashboard)
         :map dashboard-mode-map
         ("H" . my-browse-homepage)
         ("O" . my-restore-session)
         ("S" . my-open-settings)
         ("U" . my-update-system)
         ("?" . my-open-keybindings)
         ("g" . dashboard-refresh-buffer)
         ("q" . my-quit-dashboard)
         ("<escape>" . my-quit-dashboard))
  :hook (dashboard-mode . (lambda () (setq-local global-hl-line-mode nil)))
  :custom
  (dashboard-banner-logo-title "GNU EMACS - Enjoy Programming & Writing")
  (dashboard-startup-banner (expand-file-name "splash.png" my-config-directory))
  (dashboard-page-separator "\n\n")
  (dashboard-projects-backend 'project-el)
  (dashboard-path-style 'truncate-middle)
  (dashboard-path-max-length 60)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-show-shortcuts nil)
  (dashboard-items '((recents . 10) (bookmarks . 5) (projects . 5)))
  (dashboard-startupify-list '(dashboard-insert-banner
                               dashboard-insert-newline
                               dashboard-insert-banner-title
                               dashboard-insert-newline
                               dashboard-insert-navigator
                               dashboard-insert-newline
                               dashboard-insert-init-info
                               dashboard-insert-items))
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-file-icons t)
  (dashboard-set-heading-icons t)
  (dashboard-heading-icons '((recents . "nf-oct-history")
                             (bookmarks . "nf-oct-bookmark")
                             (agenda . "nf-oct-calendar")
                             (projects . "nf-oct-briefcase")
                             (registers . "nf-oct-database")))
  :config
  (setq dashboard-navigator-buttons
        `(((,(nerd-icons-mdicon "nf-md-github" :height 1.4)
            "Homepage" "Visit homepage (H)"
            (lambda (&rest _) (my-browse-homepage)))
           (,(nerd-icons-mdicon "nf-md-backup_restore" :height 1.5)
            "Restore" "Restore previous session (O)"
            (lambda (&rest _) (my-restore-session)))
           (,(nerd-icons-mdicon "nf-md-tools" :height 1.3)
            "Settings" "Open this Emacs config (S)"
            (lambda (&rest _) (my-open-settings)))
           (,(nerd-icons-mdicon "nf-md-update" :height 1.3)
            "Update" "Rebuild the system: nh os switch (U)"
            (lambda (&rest _) (my-update-system)))
           (,(nerd-icons-mdicon "nf-md-help" :height 1.2)
            "" "Key reference (?)"
            (lambda (&rest _) (my-open-keybindings)))))))

(defun my-dashboard-redraw (&rest _)
  "Draw the dashboard again, sized to a graphical window showing it."
  (when-let* ((buffer (get-buffer dashboard-buffer-name))
              (window (seq-find (lambda (window)
                                  (display-graphic-p (window-frame window)))
                                (get-buffer-window-list buffer nil t))))
    (with-selected-window window
      (dashboard-insert-startupify-lists t))))

(defun my-dashboard-fit-banner (insert &rest args)
  "Call INSERT with ARGS, with the splash art fitted to the selected window."
  (let ((dashboard-image-banner-max-width
         (floor (* 0.8 (window-body-width nil t))))
        (dashboard-image-banner-max-height
         (min 220 (floor (* 0.3 (window-body-height nil t)))))
        (dashboard-image-extra-props
         `(:mask heuristic :background ,(face-background 'default nil t))))
    (apply insert args)))
(advice-add 'dashboard-insert-banner :around #'my-dashboard-fit-banner)

(defun my-dashboard-buffer ()
  "Return the freshly drawn dashboard buffer."
  (dashboard-insert-startupify-lists t)
  (get-buffer dashboard-buffer-name))

(setq initial-buffer-choice #'my-dashboard-buffer)
(add-hook 'window-size-change-functions
          (lambda (frame)
            (when (get-buffer-window dashboard-buffer-name frame)
              (my-dashboard-redraw))))
(add-hook 'enable-theme-functions #'my-dashboard-redraw 95)
(add-hook 'server-after-make-frame-hook #'my-dashboard-redraw)

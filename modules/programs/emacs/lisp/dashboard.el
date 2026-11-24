;;; dashboard.el -*- lexical-binding: t -*-

;; Centaur Emacs's dashboard (lisp/init-dashboard.el in seagle0128/.emacs.d),
;; with this config's splash art and its own versions of Centaur's buttons:
;; H the dotfiles repo, O the last project session, S this Emacs config, U rebuild,
;; ? or h the key reference, g refresh, q close; r / m / p jump to recent
;; files, bookmarks, projects. SPC is the menu, as everywhere.

(defun my-new-file ()
  "Choose a path for a new file."
  (interactive)
  (find-file (read-file-name "New file: " default-directory nil nil)))

(defvar my-homepage "https://github.com/McKaigne/dotfiles"
  "Where the dashboard's Homepage button goes.")

;; Draws the dashboard's section separators (form feeds) as lines.
(use-package page-break-lines
  :demand t
  :config
  (dolist (mode '(dashboard-mode emacs-news-mode))
    (add-to-list 'page-break-lines-modes mode))
  (global-page-break-lines-mode 1))

(use-package dashboard
  :demand t
  :custom-face
  (dashboard-heading ((t (:inherit (font-lock-string-face bold)))))
  (dashboard-items-face ((t (:weight normal))))
  (dashboard-no-items-face ((t (:weight normal))))
  :bind (("<f2>" . open-dashboard)
         :map dashboard-mode-map
         ("H" . browse-homepage)
         ("O" . restore-session)
         ("S" . open-setting-files)
         ("U" . update-config-and-packages)
         ("?" . my-open-keybindings)
         ("h" . my-open-keybindings)
         ("g" . dashboard-refresh-buffer)
         ("q" . quit-dashboard)
         ("SPC" . meow-keypad))
  :hook (dashboard-mode . (lambda ()
                            (setq-local frame-title-format nil
                                        global-hl-line-mode nil)))
  :init
  (setq dashboard-banner-logo-title "GNU EMACS - Enjoy Programming & Writing"
        dashboard-startup-banner (expand-file-name "splash.png" my-config-directory)
        dashboard-page-separator "\n\f\n"
        dashboard-projects-backend 'project-el
        dashboard-path-style 'truncate-middle
        dashboard-path-max-length 60
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-show-shortcuts nil
        dashboard-items '((recents  . 10)
                          (bookmarks . 5)
                          (projects . 5))

        dashboard-startupify-list '(dashboard-insert-banner
                                    dashboard-insert-newline
                                    dashboard-insert-banner-title
                                    dashboard-insert-newline
                                    dashboard-insert-navigator
                                    dashboard-insert-newline
                                    dashboard-insert-init-info
                                    dashboard-insert-items)

        dashboard-icon-type 'nerd-icons
        dashboard-set-file-icons t
        dashboard-set-heading-icons t
        dashboard-heading-icons '((recents   . "nf-oct-history")
                                  (bookmarks . "nf-oct-bookmark")
                                  (agenda    . "nf-oct-calendar")
                                  (projects  . "nf-oct-briefcase")
                                  (registers . "nf-oct-database")))
  :config
  ;; Centaur checks that its icon font is installed; here it always is.
  ;; The daemon has no frame yet, so this doesn't ask the display.
  (require 'nerd-icons)
  (setq dashboard-navigator-buttons
        `(((,(nerd-icons-mdicon "nf-md-github" :height 1.4)
            "Homepage" "Visit homepage (H)"
            (lambda (&rest _) (browse-homepage)))
           (,(nerd-icons-mdicon "nf-md-backup_restore" :height 1.5)
            "Restore" "Restore previous session (O)"
            (lambda (&rest _) (restore-session)))
           (,(nerd-icons-mdicon "nf-md-tools" :height 1.3)
            "Settings" "Open this Emacs config (S)"
            (lambda (&rest _) (open-setting-files)))
           (,(nerd-icons-mdicon "nf-md-update" :height 1.3)
            "Update" "Rebuild the system: nh os switch (U)"
            (lambda (&rest _) (update-config-and-packages)))
           (,(nerd-icons-mdicon "nf-md-help" :height 1.2)
            "" "Key reference (?)"
            (lambda (&rest _) (my-open-keybindings))))))

  (defun browse-homepage ()
    "Visit the dotfiles repository."
    (interactive)
    (browse-url my-homepage))

  (defun restore-session ()
    "Restore the previous session."
    (interactive)
    (quit-dashboard)
    (project-x-restore-last-project))

  (defun open-setting-files ()
    "Open this Emacs config's source in the system flake."
    (interactive)
    (quit-dashboard)
    (find-file (file-name-directory
                (directory-file-name (file-name-directory my-keybindings-file)))))

  (defun update-config-and-packages ()
    "Rebuild and switch the system, in a terminal for sudo."
    (interactive)
    (require 'ghostel)
    (ghostel)
    (ghostel-send-string "git -C /etc/nixos add -A && nh os switch\n"))

  (defvar dashboard-recover-layout-p nil)
  (defun open-dashboard ()
    "Display dashboard in maximized window."
    (interactive)
    ;; Check if need to recover layout
    (when (length> (window-list-1)
                   ;; exclude `treemacs' window
                   (if (and (fboundp 'treemacs-current-visibility)
                            (eq (treemacs-current-visibility) 'visible))
                       2
                     1))
      (setq dashboard-recover-layout-p t)
      (delete-other-windows))
    (dashboard-open))

  (defun quit-dashboard ()
    "Quit dashboard."
    (interactive)
    (quit-window t)
    ;; Recover layout
    (when dashboard-recover-layout-p
      (and (bound-and-true-p winner-mode) (winner-undo))
      (setq dashboard-recover-layout-p nil))))

;; Centaur starts it with `dashboard-setup-startup-hook', which steps aside
;; whenever Emacs has arguments, so it never runs under this daemon. Each new
;; frame opens on it instead, drawn again once the frame has its real size.
(defun my-dashboard-redraw (&rest _)
  "Render the dashboard again, sized to a graphical window that shows it.
The daemon's hidden text frame shows it too; drawn there, the splash art
would lose its size limit."
  (when-let* ((buffer (get-buffer dashboard-buffer-name))
              (window (seq-find (lambda (window)
                                  (display-graphic-p (window-frame window)))
                                (get-buffer-window-list buffer nil t))))
    (with-selected-window window
      (dashboard-insert-startupify-lists t))))

;; The splash art is sized to the window each time the dashboard is drawn,
;; so it still fits when the window is half the frame's width or height.
;; Emacs blends partly transparent pixels into the frame's solid background
;; colour, which showed as a dark box on the glass background; masking the
;; pixels that came out exactly that colour lets the glass show through.
(defun my-dashboard-fit-banner (insert &rest args)
  "Call INSERT with ARGS, the splash art fitted to the selected window."
  (let ((dashboard-image-banner-max-width
         (floor (* 0.8 (window-body-width nil t))))
        (dashboard-image-banner-max-height
         (min 220 (floor (* 0.3 (window-body-height nil t)))))
        (dashboard-image-extra-props
         `(:mask heuristic :background ,(face-background 'default nil t))))
    (apply insert args)))
(advice-add 'dashboard-insert-banner :around #'my-dashboard-fit-banner)

(defun my-dashboard-buffer ()
  "Return the freshly rendered dashboard buffer."
  (dashboard-insert-startupify-lists t)
  (get-buffer dashboard-buffer-name))

(setq initial-buffer-choice #'my-dashboard-buffer)
(add-hook 'window-size-change-functions
          (lambda (frame)
            (when (get-buffer-window dashboard-buffer-name frame)
              (my-dashboard-redraw))))
(add-hook 'enable-theme-functions #'my-dashboard-redraw 95)
(add-hook 'server-after-make-frame-hook #'my-dashboard-redraw)

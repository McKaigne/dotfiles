;;; files.el -*- lexical-binding: t -*-

;; Files, buffers, bookmarks, the file tree and per-project sessions:
;; Centaur Emacs's dired, bookmark, ibuffer, treemacs and workspace modules,
;; with Dirvish drawing dired (its own icons replace nerd-icons-dired).

(use-package dirvish
  :demand t
  :custom
  (dirvish-attributes '(nerd-icons file-size collapse subtree-state vc-state))
  (dirvish-cache-dir (my-state-file "dirvish/"))
  :config
  (dirvish-override-dired-mode)
  (define-key dired-mode-map (kbd "q") #'dirvish-quit)
  (setq dired-kill-when-opening-new-dired-buffer t))

;; Directory operations
(use-package dired
  :ensure nil
  :bind (:map dired-mode-map
         ("C-c C-p" . wdired-change-to-wdired-mode))
  :config
  ;; Guess a default target directory
  (setq dired-dwim-target t)
  ;; Show directory first
  (setq dired-listing-switches "-alh --group-directories-first"))

;; Quick sort dired buffers via a transient menu
(use-package dired-quick-sort
  :after dired
  :bind (:map dired-mode-map
         ("S" . dired-quick-sort-transient))
  :hook (dired-mode . dired-quick-sort-set-switches))

;; Show git ignored files
(use-package dired-gitignore
  :after dired
  :bind (:map dired-mode-map
         (")" . dired-gitignore-mode)))

;; Allow rsync from dired buffers
(use-package dired-rsync
  :after dired
  :bind (:map dired-mode-map
         ("C-c C-r" . dired-rsync)))

;; Colorful dired
(use-package diredfl
  :hook (dired-mode . diredfl-mode))

;; Extra Dired functionality
(use-package dired-aux :ensure nil)
(use-package dired-x
  :ensure nil
  :demand t
  :init
  (let ((cmd "xdg-open"))
    (setq dired-guess-shell-alist-user
          `(("\\.pdf\\'" ,cmd)
            ("\\.docx\\'" ,cmd)
            ("\\.\\(?:djvu\\|eps\\)\\'" ,cmd)
            ("\\.\\(?:jpg\\|jpeg\\|png\\|gif\\|xpm\\)\\'" ,cmd)
            ("\\.\\(?:xcf\\)\\'" ,cmd)
            ("\\.csv\\'" ,cmd)
            ("\\.tex\\'" ,cmd)
            ("\\.\\(?:mp4\\|mkv\\|avi\\|flv\\|rm\\|rmvb\\|ogv\\)\\(?:\\.part\\)?\\'" ,cmd)
            ("\\.\\(?:mp3\\|flac\\)\\'" ,cmd)
            ("\\.html?\\'" ,cmd)
            ("\\.md\\'" ,cmd))))
  :config
  (setq dired-omit-files
        (concat dired-omit-files
                "\\|^.DS_Store$\\|^.projectile$\\|^.git*\\|^.svn$\\|^.vscode$\\|\\.js\\.meta$\\|\\.meta$\\|\\.elc$\\|^.emacs.*")))

;; Bookmarks: the list shows an icon and a type (file, directory, remote,
;; missing) for each.
(use-package bookmark
  :ensure nil
  :config
  (with-no-warnings
    ;; Display icons for bookmarks
    (defun my/bookmark-bmenu--revert ()
      "Re-populate `tabulated-list-entries'."
      (let (entries)
        (dolist (full-record (bookmark-maybe-sort-alist))
          (let* ((name       (bookmark-name-from-full-record full-record))
                 (annotation (bookmark-get-annotation full-record))
                 (location   (bookmark-location full-record))
                 (file       (file-name-nondirectory location))
                 (type       (let ((fmt "%-8.8s"))
                               (cond ((null location)
                                      (propertize (format fmt "NOFILE") 'face 'warning))
                                     ((file-remote-p location)
                                      (propertize (format fmt "REMOTE") 'face 'mode-line-buffer-id))
                                     ((not (file-exists-p location))
                                      (propertize (format fmt "NOTFOUND") 'face 'error))
                                     ((file-directory-p location)
                                      (propertize (format fmt "DIRED") 'face 'warning))
                                     (t (propertize (format fmt "FILE") 'face 'success)))))
                 (icon       (if (icons-displayable-p)
                                 (cond
                                  ((file-remote-p location)
                                   (nerd-icons-codicon "nf-cod-radio_tower"))
                                  ((file-directory-p location)
                                   (nerd-icons-icon-for-dir location))
                                  ((not (string-empty-p file))
                                   (nerd-icons-icon-for-file file)))
                               "")))
            (push (list
                   full-record
                   `[,(if (and annotation (not (string-equal annotation "")))
                          "*" "")
                     ,icon
                     ,(if (display-mouse-p)
                          (propertize name
                                      'font-lock-face 'bookmark-menu-bookmark
                                      'mouse-face 'highlight
                                      'follow-link t
                                      'help-echo "mouse-2: go to this bookmark in other window")
                        name)
                     ,type
                     ,@(if bookmark-bmenu-toggle-filenames
                           (list (propertize location 'face 'completions-annotations)))])
                  entries)))
        (tabulated-list-init-header)
        (setq tabulated-list-entries entries))
      (tabulated-list-print t))
    (advice-add #'bookmark-bmenu--revert :override #'my/bookmark-bmenu--revert)

    (defun my/bookmark-bmenu-list ()
      "Display a list of existing bookmarks."
      (interactive)
      (bookmark-maybe-load-default-file)
      (let ((buf (get-buffer-create bookmark-bmenu-buffer)))
        (if (called-interactively-p 'interactive)
            (pop-to-buffer buf)
          (set-buffer buf)))
      (bookmark-bmenu-mode)
      (bookmark-bmenu--revert))
    (advice-add #'bookmark-bmenu-list :override #'my/bookmark-bmenu-list)

    (define-derived-mode bookmark-bmenu-mode tabulated-list-mode "Bookmark Menu"
      (setq truncate-lines t)
      (setq buffer-read-only t)
      (setq tabulated-list-format
            `[("" 1) ;; Space to add "*" for bookmark with annotation
              ("" ,(if (icons-displayable-p) 2 0)) ;; Icons
              ("Bookmark" ,bookmark-bmenu-file-column bookmark-bmenu--name-predicate)
              ("Type" 9)
              ,@(if bookmark-bmenu-toggle-filenames
                    '(("File" 0 bookmark-bmenu--file-predicate)))])
      (setq tabulated-list-padding bookmark-bmenu-marks-width)
      (setq tabulated-list-sort-key '("Bookmark" . nil))
      (add-hook 'tabulated-list-revert-hook #'bookmark-bmenu--revert nil t)
      (setq revert-buffer-function #'bookmark-bmenu--revert)
      (tabulated-list-init-header))))

;; Buffer list (C-x C-b), grouped by project, with icons.
(use-package ibuffer
  :ensure nil
  :custom
  (ibuffer-filter-group-name-face '(:inherit (font-lock-string-face bold)))
  (ibuffer-human-readable-size t)
  :bind ("C-x C-b" . ibuffer))

(use-package ibuffer-vc
  :commands (ibuffer-vc-set-filter-groups-by-vc-root
             ibuffer-do-sort-by-vc-status)
  :custom (ibuffer-vc-buffer-file-name-function #'buffer-file-name)
  :hook (ibuffer . (lambda ()
                     "Group ibuffer's list by project."
                     (ibuffer-vc-set-filter-groups-by-vc-root)
                     (unless (eq ibuffer-sorting-mode 'project-file-relative)
                       (ibuffer-do-sort-by-vc-status))))
  :config
  (with-no-warnings
    (defun my/ibuffer-vc-generate-filter-groups-by-vc-root ()
      "Create a set of ibuffer filter groups based on the vc root dirs of buffers."
      (let ((roots (seq-uniq
                    (delq nil (mapcar 'ibuffer-vc-root (buffer-list))))))
        (mapcar (lambda (vc-root)
                  (cons (format "%s: %s"
                                (nerd-icons-octicon "nf-oct-repo"
                                                    :height 1.2
                                                    :face ibuffer-filter-group-name-face)
                                (cdr vc-root))
                        `((vc-root . ,vc-root))))
                roots)))
    (advice-add #'ibuffer-vc-generate-filter-groups-by-vc-root
                :override #'my/ibuffer-vc-generate-filter-groups-by-vc-root)))

(use-package nerd-icons-ibuffer
  :custom
  (nerd-icons-ibuffer-icon t)
  (nerd-icons-ibuffer-formats '((mark modified read-only locked vc-status-mini
                                      " " (icon 2 2) (name 18 18 :left :elide)
                                      " " (size-h 9 -1 :right)
                                      " " (mode+ 16 16 :left :elide)
                                      " " (vc-status 16 16 :left)
                                      " " filename-and-process+)
                                (mark " " (name 16 -1) " " filename)))
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

;; The file tree
(use-package treemacs
  :functions (treemacs-follow-mode
              treemacs-filewatch-mode
              treemacs-git-mode
              treemacs-set-scope-type)
  :custom-face
  (cfrs-border-color ((t (:inherit posframe-border))))
  :bind (([f8]        . treemacs)
         ("M-0"       . treemacs-select-window)
         ("C-x t 1"   . treemacs-delete-other-windows)
         ("C-x t t"   . treemacs)
         ("C-x t b"   . treemacs-bookmark)
         ("C-x t C-t" . treemacs-find-file)
         ("C-x t M-t" . treemacs-find-tag)
         :map treemacs-mode-map
         ([mouse-1]   . treemacs-single-click-expand-action))
  :custom
  (treemacs-persist-file (my-state-file "treemacs-persist"))
  (treemacs-last-error-persist-file (my-state-file "treemacs-errors"))
  :config
  (setq treemacs-collapse-dirs           (if treemacs-python-executable 3 0)
        treemacs-missing-project-action  'remove
        treemacs-user-mode-line-format   'none
        treemacs-sorting                 'alphabetic-asc
        treemacs-follow-after-init       t
        treemacs-width                   30
        treemacs-no-png-images           nil)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (pcase (cons (not (null (executable-find "git")))
               (not (null (executable-find "python3"))))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))

  (use-package treemacs-nerd-icons
    :autoload treemacs-nerd-icons-config
    :init (treemacs-nerd-icons-config))

  (use-package treemacs-magit
    :demand t)

  (use-package treemacs-tab-bar
    :demand t
    :config (treemacs-set-scope-type 'Tabs)))

;; Per-project sessions: each project gets a tab (hidden) and its windows
;; and buffers are saved every 30 seconds, so a project reopens as you left
;; it. The dashboard's Restore button (O) reopens the last one.
(use-package project-x
  :custom
  (project-x-auto-save-delay 30) ; nil to disable autosave
  (project-prompter #'project-x--project-prompt)
  (project-x-restore-last-project-on-startup nil)
  (tab-bar-show nil)
  :hook
  (after-init     . project-x-mode)
  (project-x-mode . project-x-tabs-mode))
(project-x-mode 1)

(defun my-file-manager ()
  "Browse the current file's directory or the buffer's working directory."
  (interactive)
  (dirvish (if buffer-file-name
               (file-name-directory buffer-file-name)
             default-directory)))

(defun my-new-buffer ()
  "Create an unnamed text buffer in the current directory."
  (interactive)
  (let ((directory default-directory))
    (switch-to-buffer (generate-new-buffer "untitled"))
    (text-mode)
    (setq-local default-directory directory)))

(defun my-project-open ()
  "Choose a project and find a file in it."
  (interactive)
  (let ((default-directory (project-prompt-project-dir)))
    (project-find-file)))


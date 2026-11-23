;;; funcs.el -*- lexical-binding: t -*-

;; Centaur Emacs's helper functions (lisp/init-funcs.el), minus the ones for
;; its theme switcher, package archives, self-update and frame geometry: the
;; theme is Noctalia's, packages are Nix's, and Umbriel tiles the frames.

(defun font-available-p (font-name)
  "Check if font with FONT-NAME is available."
  (find-font (font-spec :name font-name)))

;; The platform constants Centaur's modules test (init-const.el), for this
;; machine: Linux, Emacs 31.
(defconst sys/win32p nil)
(defconst sys/macp nil)
(defconst sys/mac-port-p nil)
(defconst sys/linuxp t)
(defconst sys/unixp t)
(defconst emacs/>=29p t)
(defconst emacs/>=31p t)

;; Dos2Unix/Unix2Dos
(defun dos2unix ()
  "Convert the current buffer to UNIX file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix nil))

(defun unix2dos ()
  "Convert the current buffer to DOS file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-dos nil))

(defun delete-dos-eol ()
  "Delete `^M' characters in current region or buffer.
Same as `replace-string' `C-q' `C-m' `RET' `RET'."
  (interactive)
  (save-excursion
    (when (region-active-p)
      (narrow-to-region (region-beginning) (region-end)))
    (goto-char (point-min))
    (let ((count 0))
      (while (search-forward "\r" nil t)
        (replace-match "" nil t)
        (setq count (1+ count)))
      (message "Removed %d " count))
    (widen)))

;; File and buffer
(defun delete-this-file ()
  "Delete the current file, and kill the buffer."
  (interactive)
  (unless (buffer-file-name)
    (error "No file is currently being edited"))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-current-buffer)))

(defun rename-this-file (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (progn
      (when (file-exists-p filename)
        (rename-file filename new-name 1))
      (set-visited-file-name new-name)
      (rename-buffer new-name))))

(defun browse-this-file ()
  "Open the current file as a URL using `browse-url'."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if (and (fboundp 'tramp-tramp-file-p)
             (tramp-tramp-file-p file-name))
        (error "Cannot open tramp file")
      (browse-url (concat "file://" file-name)))))

(defun create-scratch-buffer ()
  "Create a scratch buffer."
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode))

(defun save-buffer-as-utf8 (coding-system)
  "Revert a buffer with `CODING-SYSTEM' and save as UTF-8."
  (interactive "zCoding system for visited file (default nil):")
  (revert-buffer-with-coding-system coding-system)
  (set-buffer-file-coding-system 'utf-8)
  (save-buffer))

(defun selected-region-or-symbol-at-point ()
  "Return the selected region, otherwise return the symbol at point."
  (if (region-active-p)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (thing-at-point 'symbol t)))

;; Browse URL
(defun xwidget-workable-p ()
  "Check whether xwidget is available."
  (and (display-graphic-p)
       (featurep 'xwidget-internal)))

(defun centaur-webkit-browse-url (url &optional pop-buffer new-session)
  "Browse URL with xwidget-webkit' and switch or pop to the buffer.
POP-BUFFER specifies whether to pop to the buffer.
NEW-SESSION specifies whether to create a new xwidget-webkit session."
  (interactive (progn
                 (require 'browse-url)
                 (browse-url-interactive-arg "URL: ")))
  (xwidget-webkit-browse-url url new-session)
  (let ((buf (xwidget-buffer (xwidget-webkit-current-session))))
    (when (buffer-live-p buf)
      (and (eq buf (current-buffer)) (quit-window))
      (if pop-buffer
          (pop-to-buffer buf)
        (switch-to-buffer buf)))))

(defun centaur-browse-url (url)
  "Open URL using a configurable method.
See `browse-url' for more details."
  (interactive)
  (if (xwidget-workable-p)
      (centaur-webkit-browse-url url t)
    (browse-url url)))

(defun centaur-browse-url-of-file (file)
  "Use a web browser to display FILE."
  (interactive)
  (if (xwidget-workable-p)
      (centaur-webkit-browse-url (browse-url-file-url file) t)
    (browse-url-of-file file)))

;; Reload configurations
(defun reload-init-file ()
  "Reload Emacs configurations."
  (interactive)
  (when (yes-or-no-p "Really reload Emacs configurations?")
    (load early-init-file)
    (load user-init-file)
    (run-hooks 'after-init-hook 'window-setup-hook 'emacs-startup-hook)))
(defalias 'centaur-reload-init-file #'reload-init-file)

(defun icons-displayable-p ()
  "Return non-nil if icons are displayable."
  (or (featurep 'nerd-icons)
      (require 'nerd-icons nil t)))

(defun centaur-treesit-available-p ()
  "Check whether tree-sitter is available."
  (and (fboundp 'treesit-available-p)
       (treesit-available-p)))

(defun file-too-big-p ()
  "Check whether the file is too big.
Returns non-nil if the buffer size exceeds 999,999 bytes or has more than 10,000
lines, or more than 2,000 bytes in one line."
  (or (> (buffer-size) 999999)
      (and (fboundp 'buffer-line-statistics)
           (let ((statics (buffer-line-statistics)))
             (or (> (car statics) 10000)
                 (> (cadr statics) 2000))))))

(define-minor-mode centaur-read-mode
  "Minor Mode for better reading experience."
  :init-value nil
  (if centaur-read-mode
      (progn
        (and (fboundp 'olivetti-mode) (olivetti-mode 1))
        (and (fboundp 'mixed-pitch-mode) (mixed-pitch-mode 1))
        (text-scale-set +1))
    (progn
      (and (fboundp 'olivetti-mode) (olivetti-mode -1))
      (and (fboundp 'mixed-pitch-mode) (mixed-pitch-mode -1))
      (text-scale-set 0))))

;; Theme
(defvar after-load-theme-hook nil
  "Hook run after a color theme is loaded using `load-theme'.")
(defun run-after-load-theme-hook (&rest _)
  "Run `after-load-theme-hook'."
  (run-hooks 'after-load-theme-hook))
(add-hook 'enable-theme-functions #'run-after-load-theme-hook)

(defun childframe-workable-p ()
  "Whether childframe is workable."
  (and (not noninteractive)
       (not emacs-basic-display)
       (or (display-graphic-p)
           (featurep 'tty-child-frames))
       (eq (frame-parameter (selected-frame) 'minibuffer) 't)))

(defun childframe-completion-workable-p ()
  "Whether childframe completion is workable."
  (childframe-workable-p))

(defun centaur-dark-theme-p ()
  "Check if the current theme is a dark theme."
  (eq (frame-parameter nil 'background-mode) 'dark))

;; Window
(defun split-window-horizontally-instead ()
  "Kill other windows and split the current window is on the top half of the frame."
  (interactive)
  (let* ((next-window (next-window))
         (other-buffer (and next-window (window-buffer next-window))))
    (delete-other-windows)
    (split-window-horizontally)
    (when other-buffer
      (set-window-buffer next-window other-buffer))))

(defun split-window-vertically-instead ()
  "Kill other windows and split the current window is on left half of the frame."
  (interactive)
  (let* ((next-window (next-window))
         (other-buffer (and next-window (window-buffer next-window))))
    (delete-other-windows)
    (split-window-vertically)
    (when other-buffer
      (set-window-buffer next-window other-buffer))))

(defun split-window-toggle ()
  "Toggle window split style: top/below or left/right."
  (interactive)
  (if (fboundp 'window-layout-rotate-clockwise)
      (window-layout-rotate-clockwise)
    (user-error "`split-window-toggle' needs Emacs 31")))

;; Centaur's hydras as Meow menus. `my-define-menu' makes a command that
;; shows its keys (in which-key's popup) and keeps them live, the way a hydra
;; stays open: SPC w, then + + + keeps growing the window. An :exit entry,
;; q, C-g or any key not in the menu closes it. The keys only exist while
;; the menu is open, so they never change editing elsewhere.
(defmacro my-define-menu (name title &rest body)
  "Define NAME, a command that opens a menu titled TITLE.
BODY starts with optional :pre FORM (run on opening) and :post FORM (run
on closing), then entries (KEY COMMAND DESCRIPTION [:exit t])."
  (declare (indent 2))
  (let (pre post)
    (while (keywordp (car body))
      (pcase (pop body)
        (:pre (setq pre (pop body)))
        (:post (setq post (pop body)))))
    (let ((map (intern (format "%s-map" name)))
          (exit (intern (format "%s--exit" name)))
          (show (intern (format "%s--show" name))))
      `(progn
         (defvar ,exit nil "Closes the open menu.")
         (defvar ,map
           (let ((map (make-sparse-keymap ,title)))
             ,@(mapcar
                (lambda (entry)
                  (pcase-let ((`(,key ,command ,description . ,props) entry))
                    `(define-key map (kbd ,key)
                                 (cons ,description
                                       ,(if (plist-get props :exit)
                                            `(lambda ()
                                               (interactive)
                                               (when ,exit (funcall ,exit))
                                               (call-interactively ,command))
                                          command)))))
                body)
             (define-key map (kbd "q")
                         (cons "quit" (lambda () (interactive)
                                        (when ,exit (funcall ,exit)))))
             map))
         (defun ,show ()
           (if ,exit
               (which-key--create-buffer-and-show nil ,map nil ,title)
             (remove-hook 'post-command-hook #',show)))
         (defun ,name ()
           ,(format "Open the %s menu." title)
           (interactive)
           ,pre
           (setq ,exit
                 (set-transient-map
                  ,map t
                  (lambda ()
                    (setq ,exit nil)
                    (remove-hook 'post-command-hook #',show)
                    (which-key--hide-popup)
                    ,post)))
           (add-hook 'post-command-hook #',show)
           (,show))))))

;;; core.el -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'subr-x)
(require 'use-package)
(require 'project)

(defvar my-state-directory
  (expand-file-name "emacs/"
                    (or (getenv "XDG_STATE_HOME")
                        (expand-file-name "~/.local/state/"))))
(make-directory my-state-directory t)

(defun my-state-file (name)
  "Return a writable state path for NAME."
  (expand-file-name name my-state-directory))

(add-to-list 'exec-path my-tools-directory t)
(setenv "PATH" (concat (getenv "PATH") path-separator my-tools-directory))
;; Marks programs this Emacs starts, so the emacsclient wrapper can refuse to
;; wait on the Emacs that is waiting on it (default.nix).
(setenv "EMACS_DAEMON_CHILD" "1")
(setq custom-file (my-state-file "custom.el")
      backup-directory-alist `(("." . ,(my-state-file "backups/")))
      auto-save-file-name-transforms `((".*" ,(my-state-file "auto-save/") t))
      auto-save-list-file-prefix (my-state-file "auto-save/.saves-")
      recentf-save-file (my-state-file "recentf")
      savehist-file (my-state-file "history")
      save-place-file (my-state-file "places")
      project-list-file (my-state-file "projects")
      bookmark-default-file (my-state-file "bookmarks")
      url-history-file (my-state-file "url-history")
      tramp-persistency-file-name (my-state-file "tramp")
      eshell-directory-name (my-state-file "eshell/")
      create-lockfiles nil
      use-short-answers t
      ring-bell-function #'ignore
      read-process-output-max (* 1024 1024)
      recentf-max-saved-items 150
      history-length 200)
(dolist (directory '("backups" "auto-save"))
  (make-directory (my-state-file directory) t))
(load custom-file t t)
(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(setq select-enable-clipboard t
      select-enable-primary t)
(defun my-copy-to-clipboard (text)
  "Send TEXT to the Wayland clipboard without blocking Emacs."
  (let ((process-environment (append (frame-parameter nil 'environment)
                                     process-environment)))
    (if (and (getenv "WAYLAND_DISPLAY") (executable-find "wl-copy"))
        (let ((process (make-process :name "emacs-wl-copy"
                                     :command '("wl-copy" "--type" "text/plain")
                                     :connection-type 'pipe :noquery t)))
          (process-send-string process text)
          (process-send-eof process))
      (gui-select-text text))))
(defun my-paste-from-clipboard ()
  "Read the Wayland clipboard when it contains text."
  (let ((process-environment (append (frame-parameter nil 'environment)
                                     process-environment)))
    (if (and (getenv "WAYLAND_DISPLAY") (executable-find "wl-paste"))
        (with-temp-buffer
          (when (zerop (call-process "wl-paste" nil t nil "--no-newline" "--type" "text"))
            (buffer-string)))
      (gui-selection-value))))
(setq interprogram-cut-function #'my-copy-to-clipboard
      interprogram-paste-function #'my-paste-from-clipboard)

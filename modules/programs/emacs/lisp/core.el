;;; core.el -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'subr-x)
(require 'use-package)

(defvar my-state-directory
  (expand-file-name "emacs/" (or (getenv "XDG_STATE_HOME")
                                 (expand-file-name "~/.local/state/"))))
(make-directory my-state-directory t)

(defun my-state-file (name)
  "Return the path of NAME inside the state directory."
  (expand-file-name name my-state-directory))

(add-to-list 'exec-path my-tools-directory t)
(setenv "PATH" (concat (getenv "PATH") path-separator my-tools-directory))
(setenv "EMACS_DAEMON_CHILD" "1")

(setq custom-file (my-state-file "custom.el")
      url-history-file (my-state-file "url-history")
      url-configuration-directory (my-state-file "url/")
      tramp-persistency-file-name (my-state-file "tramp")
      recentf-save-file (my-state-file "recentf")
      savehist-file (my-state-file "history")
      save-place-file (my-state-file "places")
      bookmark-default-file (my-state-file "bookmarks")
      project-list-file (my-state-file "projects")
      transient-history-file (my-state-file "transient/history.el")
      transient-levels-file (my-state-file "transient/levels.el")
      transient-values-file (my-state-file "transient/values.el")
      desktop-dirname (my-state-file "desktop/")
      desktop-path (list (my-state-file "desktop/"))
      auto-save-list-file-prefix (my-state-file "auto-save/sessions-")
      backup-directory-alist `(("." . ,(my-state-file "backup/")))
      create-lockfiles nil
      read-process-output-max (* 1024 1024)
      use-short-answers t
      ring-bell-function #'ignore
      recentf-max-saved-items 300
      history-length 1000
      kill-do-not-save-duplicates t
      sentence-end-double-space nil)
(make-directory (my-state-file "desktop/") t)
(load custom-file t t)

(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 100)

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
  "Return the Wayland clipboard's text."
  (let ((process-environment (append (frame-parameter nil 'environment)
                                     process-environment)))
    (if (and (getenv "WAYLAND_DISPLAY") (executable-find "wl-paste"))
        (with-temp-buffer
          (when (zerop (call-process "wl-paste" nil t nil "--no-newline" "--type" "text"))
            (buffer-string)))
      (gui-selection-value))))

(setq interprogram-cut-function #'my-copy-to-clipboard
      interprogram-paste-function #'my-paste-from-clipboard)

(use-package gcmh
  :demand t
  :custom
  (gcmh-idle-delay 'auto)
  (gcmh-auto-idle-delay-factor 10)
  (gcmh-high-cons-threshold (* 64 1024 1024))
  :config
  (gcmh-mode 1))

(savehist-mode 1)
(recentf-mode 1)
(save-place-mode 1)
(winner-mode 1)
(repeat-mode 1)
(global-auto-revert-mode 1)

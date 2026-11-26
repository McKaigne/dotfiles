;;; core.el -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'subr-x)
(require 'use-package)

(defvar nixmacs-state-directory
  (expand-file-name "emacs/" (or (getenv "XDG_STATE_HOME")
                                 (expand-file-name "~/.local/state/"))))
(make-directory nixmacs-state-directory t)

(defun nixmacs-state-file (name)
  "Return the path of NAME inside the state directory."
  (expand-file-name name nixmacs-state-directory))

(add-to-list 'exec-path nixmacs-tools-directory t)
(setenv "PATH" (concat (getenv "PATH") path-separator nixmacs-tools-directory))
(setenv "EMACS_DAEMON_CHILD" "1")

(setq custom-file (nixmacs-state-file "custom.el")
      url-history-file (nixmacs-state-file "url-history")
      url-configuration-directory (nixmacs-state-file "url/")
      tramp-persistency-file-name (nixmacs-state-file "tramp")
      recentf-save-file (nixmacs-state-file "recentf")
      savehist-file (nixmacs-state-file "history")
      save-place-file (nixmacs-state-file "places")
      bookmark-default-file (nixmacs-state-file "bookmarks")
      project-list-file (nixmacs-state-file "projects")
      transient-history-file (nixmacs-state-file "transient/history.el")
      transient-levels-file (nixmacs-state-file "transient/levels.el")
      transient-values-file (nixmacs-state-file "transient/values.el")
      desktop-dirname (nixmacs-state-file "desktop/")
      desktop-path (list (nixmacs-state-file "desktop/"))
      auto-save-list-file-prefix (nixmacs-state-file "auto-save/sessions-")
      backup-directory-alist `(("." . ,(nixmacs-state-file "backup/")))
      create-lockfiles nil
      read-process-output-max (* 1024 1024)
      use-short-answers t
      ring-bell-function #'ignore
      recentf-max-saved-items 300
      history-length 1000
      kill-do-not-save-duplicates t
      project-switch-commands #'project-find-file
      sentence-end-double-space nil)
(make-directory (nixmacs-state-file "desktop/") t)
(load custom-file t t)

(setq-default indent-tabs-mode nil
              tab-width 2
              fill-column 100)

(setq select-enable-clipboard t
      select-enable-primary t)

(defvar nixmacs-clipboard-last nil)

(defun nixmacs-copy-to-clipboard (text)
  "Send TEXT to the Wayland clipboard without blocking Emacs."
  (setq nixmacs-clipboard-last text)
  (let ((process-environment (append (frame-parameter nil 'environment)
                                     process-environment)))
    (if (and (getenv "WAYLAND_DISPLAY") (executable-find "wl-copy"))
        (let ((process (make-process :name "emacs-wl-copy"
                                     :command '("wl-copy" "--type" "text/plain")
                                     :connection-type 'pipe :noquery t)))
          (process-send-string process text)
          (process-send-eof process))
      (gui-select-text text))))

(defun nixmacs-paste-from-clipboard ()
  "Return the Wayland clipboard's text when another program set it."
  (let* ((process-environment (append (frame-parameter nil 'environment)
                                      process-environment))
         (text (if (and (getenv "WAYLAND_DISPLAY") (executable-find "wl-paste"))
                   (with-temp-buffer
                     (when (zerop (call-process "wl-paste" nil t nil "--no-newline" "--type" "text"))
                       (buffer-string)))
                 (gui-selection-value))))
    (unless (or (null text) (string-empty-p text) (equal text nixmacs-clipboard-last))
      (setq nixmacs-clipboard-last text))))

(setq interprogram-cut-function #'nixmacs-copy-to-clipboard
      interprogram-paste-function #'nixmacs-paste-from-clipboard)

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

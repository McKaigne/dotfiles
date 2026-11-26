;;; early-init.el -*- lexical-binding: t -*-

(setq gc-cons-threshold most-positive-fixnum
      package-archives nil
      package-quickstart nil
      inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      frame-inhibit-implied-resize t
      frame-resize-pixelwise t)
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 32 1024 1024))))
(load (expand-file-name "paths.el" user-emacs-directory) nil t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(add-to-list 'default-frame-alist `(font . ,(format "%s-11" nixmacs-font)))
(setq-default mode-line-format nil)

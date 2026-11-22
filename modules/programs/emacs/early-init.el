;;; early-init.el -*- lexical-binding: t -*-

;; No garbage collection while starting up; a sane threshold afterwards.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 32 1024 1024))))

(setq package-enable-at-startup nil
      inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      frame-inhibit-implied-resize t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
;; Font for GUI frames (the system font, appearance/_style.nix).
(add-to-list 'default-frame-alist '(font . "Maple Mono NF-11"))
;; No unstyled mode line flashing in before the theme and doom-modeline.
(setq-default mode-line-format nil)
;; A little breathing room between the window edge and the text.
(add-to-list 'default-frame-alist '(internal-border-width . 12))

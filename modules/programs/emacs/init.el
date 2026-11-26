;;; init.el -*- lexical-binding: t -*-

(defvar nixmacs-config-directory
  (file-name-directory (or load-file-name user-init-file)))
(load (expand-file-name "paths.el" nixmacs-config-directory) nil t)

(dolist (file '(core ui windows editing completion dev notes tools dashboard keys))
  (load (expand-file-name (format "lisp/%s.el" file) nixmacs-config-directory) nil t))

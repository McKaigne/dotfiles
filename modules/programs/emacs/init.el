;;; init.el -*- lexical-binding: t -*-

(defvar my-config-directory
  (file-name-directory (or load-file-name user-init-file)))
(load (expand-file-name "paths.el" my-config-directory) nil t)

(dolist (file '(core ui editing completion dev notes tools dashboard keys))
  (load (expand-file-name (format "lisp/%s.el" file) my-config-directory) nil t))

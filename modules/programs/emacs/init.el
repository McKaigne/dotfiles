;;; init.el -*- lexical-binding: t -*-

(defvar my-config-directory
  (file-name-directory (or load-file-name user-init-file))
  "Directory containing the deployed Emacs configuration.")
(load (expand-file-name "paths.el" my-config-directory) nil t)

(dolist (module '(core editing completion ui files development notes dashboard extras keys))
  (load (expand-file-name (format "lisp/%s.el" module) my-config-directory) nil t))

(add-hook 'after-init-hook #'envrc-global-mode)

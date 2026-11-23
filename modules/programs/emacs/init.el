;;; init.el -*- lexical-binding: t -*-

(defvar my-config-directory
  (file-name-directory (or load-file-name user-init-file))
  "Directory containing the deployed Emacs configuration.")
(load (expand-file-name "paths.el" my-config-directory) nil t)

;; Centaur Emacs's modules, in its order, around this config's own: core
;; (paths, clipboard), editing (Meow), files, development, notes, dashboard
;; and keys (the Space menu, last).
(dolist (module '(core funcs base editing completion ui highlight window files
                  vc shell development langs notes tools dashboard keys))
  (load (expand-file-name (format "lisp/%s.el" module) my-config-directory) nil t))

(add-hook 'after-init-hook #'envrc-global-mode)

;; -*- no-byte-compile: t; -*-
;;; packages.el

(package! catppuccin-theme)
(package! avy)
(package! eca :recipe (:host github :repo "editor-code-assistant/eca-emacs" :files ("*.el")))
(package! doom-nano-modeline :recipe (:host github :repo "ronisbr/doom-nano-modeline"))
(package! hide-mode-line)
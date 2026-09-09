
;; -*- no-byte-compile: t; -*-
;;; packages.el

(package! avy)
(package! eca :recipe (:host github :repo "editor-code-assistant/eca-emacs" :files ("*.el")))
(package! doom-nano-modeline :recipe (:host github :repo "ronisbr/doom-nano-modeline"))
(package! doom-nano-themes :recipe (:host github :repo "ronisbr/doom-nano-themes"))
(package! hide-mode-line)

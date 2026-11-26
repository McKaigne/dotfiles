;;; completion.el -*- lexical-binding: t -*-

(setq enable-recursive-minibuffers t
      read-extended-command-predicate #'command-completion-default-include-p
      completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t
      tab-always-indent 'complete)

(use-package vertico
  :demand t
  :custom
  (vertico-cycle t)
  (vertico-count 14)
  :config
  (keymap-set vertico-map "<escape>" #'abort-minibuffers)
  (vertico-mode 1))

(use-package vertico-directory
  :after vertico
  :bind (:map vertico-map
         ("RET" . vertico-directory-enter)
         ("DEL" . vertico-directory-delete-char)
         ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vertico-repeat
  :after vertico
  :hook (minibuffer-setup . vertico-repeat-save))

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion))
                                   (eglot (styles orderless))
                                   (eglot-capf (styles orderless)))))

(use-package marginalia
  :demand t
  :config
  (marginalia-mode 1))

(use-package nerd-icons-completion
  :after marginalia
  :demand t
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode 1))

(use-package consult
  :demand t
  :custom
  (consult-narrow-key "<")
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (register-preview-function #'consult-register-format)
  :config
  (advice-add #'register-preview :override #'consult-register-window)
  (consult-customize consult-ripgrep consult-git-grep consult-grep
                     consult-bookmark consult-recent-file
                     :preview-key '(:debounce 0.3 any)))

(use-package embark
  :demand t)

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :config
  (keymap-set corfu-map "<escape>" #'nixmacs-escape-insert)
  (global-corfu-mode 1))

(use-package corfu-popupinfo
  :after corfu
  :demand t
  :config
  (corfu-popupinfo-mode 1))

(use-package nerd-icons-corfu
  :after corfu
  :demand t
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :demand t
  :config
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 90))

(use-package yasnippet
  :demand t
  :config
  (yas-global-mode 1))

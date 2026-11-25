;;; tools.el -*- lexical-binding: t -*-

(setq ghostel-module-directory my-ghostel-module-directory
      ghostel-module-auto-install nil)

(use-package ghostel
  :commands (ghostel ghostel-project)
  :custom
  (ghostel-keymap-exceptions
   '("C-c" "C-x" "C-u" "C-h" "M-x" "M-:" "C-\\"
     "C-." "M-SPC" "M-h" "M-j" "M-k" "M-l"))
  :config
  (keymap-set ghostel-mode-map "M-SPC" #'meow-keypad))

(defun my-ghostel-project ()
  "Open a terminal in the project root, or here outside a project."
  (interactive)
  (if (project-current) (ghostel-project) (ghostel)))

(use-package dirvish
  :demand t
  :custom
  (dirvish-attributes '(nerd-icons subtree-state vc-state file-size))
  (dirvish-side-width 32)
  (dired-listing-switches "-l --almost-all --human-readable --group-directories-first --no-group")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  :config
  (require 'dirvish-side)
  (require 'dirvish-subtree)
  (dirvish-override-dired-mode 1)
  (dirvish-side-follow-mode 1))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-key helpful-command
             helpful-at-point))

(defvar-local my-markdown-preview-source nil)

(defun my-markdown-render-code (dom)
  "Render DOM as inline code."
  (shr-fontize-dom dom 'org-code))

(defun my-markdown-render-code-block (dom)
  "Render DOM as a code block, keeping its whitespace."
  (let ((start (point)))
    (shr-tag-pre dom)
    (shr-add-font start (point) 'org-block)))

(defun my-markdown-preview ()
  "Render Markdown in a reading pane, or refresh its preview."
  (interactive)
  (require 'eww)
  (require 'markdown-mode)
  (let* ((source (or my-markdown-preview-source (current-buffer)))
         (html (generate-new-buffer " *Markdown HTML*"))
         preview)
    (unwind-protect
        (with-current-buffer source
          (unless (derived-mode-p 'markdown-mode 'markdown-ts-mode)
            (user-error "Open a Markdown buffer first"))
          (let* ((name (buffer-name))
                 (directory default-directory)
                 (url (url-encode-url (concat "file://" (or buffer-file-name directory))))
                 (text (save-restriction (widen) (buffer-string))))
            (with-temp-buffer
              (insert text)
              (delay-mode-hooks (markdown-mode))
              (let ((mark-active nil))
                (markdown-standalone (buffer-name html) name)))
            (setq preview (get-buffer-create (format "*Markdown: %s*" name)))
            (with-current-buffer preview
              (eww-mode)
              (setq-local my-markdown-preview-source source
                          default-directory directory
                          shr-use-fonts nil
                          shr-use-colors nil
                          shr-inhibit-images t
                          shr-table-horizontal-line ?─
                          shr-table-vertical-line ?│
                          shr-table-corner ?┼
                          shr-external-rendering-functions
                          '((code . my-markdown-render-code)
                            (pre . my-markdown-render-code-block))
                          eww-data (list :url url))
              (dotimes (index 6)
                (face-remap-add-relative
                 (intern (format "shr-h%d" (1+ index)))
                 :inherit (intern (format "org-level-%d" (1+ index)))
                 :height 1.0 :weight 'bold :slant 'normal))
              (let ((map (copy-keymap eww-mode-map)))
                (keymap-set map "g" #'my-markdown-preview)
                (use-local-map map)))
            (pop-to-buffer preview
                           '((display-buffer-reuse-window display-buffer-in-side-window)
                             (side . right) (slot . 0) (window-width . 0.5)))
            (with-current-buffer html
              (goto-char (point-min))
              (eww-display-html 'utf-8 url nil nil preview))
            (with-current-buffer preview (set-buffer-modified-p nil))))
      (kill-buffer html))
    (set-buffer preview)))

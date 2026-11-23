;;; notes.el -*- lexical-binding: t -*-

;; Org and Markdown: this config's notes setup (its folders, capture
;; templates, TODO keywords and babel safety check) with Centaur Emacs's Org
;; and Markdown modules on top (lisp/init-org.el, init-markdown.el).

(defvar my-org-directory (expand-file-name "~/Areas/Org/")
  "Root directory for notes, journal entries, and tasks.")

(defun my-org-confirm-babel-evaluate (_language _body)
  "Ask before executing source blocks outside the local notes directory."
  (not (and buffer-file-name
            (not (file-remote-p buffer-file-name))
            (file-in-directory-p (file-truename buffer-file-name)
                                 (file-truename my-org-directory)))))

(use-package org
  :demand t
  :custom-face (org-ellipsis ((t (:foreground unspecified))))
  :bind (("C-c o a" . org-agenda)
         ("C-c o b" . org-switchb)
         ("C-c o x" . org-capture))
  :hook (((org-babel-after-execute org-mode) . org-redisplay-inline-images) ; display image
         (org-indent-mode . (lambda()
                              (make-variable-buffer-local 'show-paren-mode)
                              (setq show-paren-mode nil))))
  :custom
  (org-directory my-org-directory)
  (org-default-notes-file (expand-file-name "inbox.org" org-directory))
  (org-agenda-files (list (expand-file-name "inbox.org" org-directory)
                          (expand-file-name "tasks.org" org-directory)
                          (expand-file-name "journal" org-directory)))
  (org-hide-emphasis-markers t)
  (org-pretty-entities nil)
  (org-ellipsis (if (char-displayable-p ?⏷) "\t⏷" nil))
  (org-startup-indented t)
  (org-modules nil)                     ; Faster loading
  (org-todo-keyword-faces '(("WAIT" . warning)))
  (org-priority-faces '((?A . error)
                        (?B . warning)
                        (?C . success)))
  (org-agenda-block-separator ?─)
  (org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"))
  (org-agenda-current-time-string
   "⭠ now ─────────────────────────────────────────────────")
  (org-tags-column -80)
  (org-catch-invisible-edits 'smart)
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-startup-folded 'content)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(300))
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-confirm-babel-evaluate #'my-org-confirm-babel-evaluate)
  :config
  (setq org-id-locations-file (my-state-file "org-id-locations")
        org-persist-directory (my-state-file "org-persist/")
        org-clock-persist-file (my-state-file "org-clock-save.el")
        org-capture-templates
        `(("t" "Task" entry (file+headline ,org-default-notes-file "Tasks")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
          ("n" "Quick note" entry (file+headline ,org-default-notes-file "Notes")
           "* %?\n%U\n")
          ("j" "Journal" entry
           (file+olp+datetree ,(expand-file-name "journal/log.org" org-directory))
           "* %U %?\n")))
  (add-to-list 'org-structure-template-alist '("n" . "note"))
  (add-to-list 'org-file-apps
               '("\\.\\(x?html?\\|pdf\\)\\'"
                 .
                 (lambda (file _link)
                   (centaur-browse-url-of-file (browse-url-file-url file)))))

  ;; Add gfm/md backends
  (add-to-list 'org-export-backends 'md)
  (require 'ox-md)
  (use-package ox-gfm
    :init (add-to-list 'org-export-backends 'gfm))

  ;; Babel
  (defconst load-language-alist
    '((emacs-lisp . t)
      (perl       . t)
      (python     . t)
      (ruby       . t)
      (js         . t)
      (css        . t)
      (sass       . t)
      (C          . t)
      (java       . t)
      (shell      . t)
      (plantuml   . t))
    "Alist of org ob languages.")

  (use-package ob-go
    :init (cl-pushnew '(go . t) load-language-alist))

  (use-package ob-powershell
    :init (cl-pushnew '(powershell . t) load-language-alist))

  (use-package ob-rust
    :init (cl-pushnew '(rust . t) load-language-alist))

  (use-package ob-mermaid
    :init (cl-pushnew '(mermaid . t) load-language-alist))

  (org-babel-do-load-languages 'org-babel-load-languages
                               load-language-alist)

  (defun hot-expand (str &optional mod)
    "Expand org template.
STR is a structure template string recognised by org like <s. MOD is a
string with additional parameters to add the begin line of the
structure element."
    (let (text)
      (when (region-active-p)
        (setq text (buffer-substring (region-beginning) (region-end)))
        (delete-region (region-beginning) (region-end)))
      (insert str)
      (require 'org-tempo nil t)
      (org-tempo-complete-tag)
      (when mod (insert mod) (forward-line))
      (when text (insert text)))))

;; A source block language picker. Org's own list has C but not cpp, and a
;; C++ block marked C is compiled as C.
(defconst my-org-src-languages
  '("cpp" "sh" "python" "emacs-lisp" "C" "java" "js" "css" "go" "rust" "ruby"
    "perl" "powershell" "plantuml" "mermaid")
  "Languages the source block picker offers, in the order shown.")

(defun my-org-insert-src-block (language)
  "Insert a source block in LANGUAGE and start typing inside it."
  (interactive
   (list (completing-read
          "Language: "
          (lambda (string predicate action)
            (if (eq action 'metadata)
                '(metadata (display-sort-function . identity)
                           (cycle-sort-function . identity))
              (complete-with-action action my-org-src-languages string predicate)))
          nil nil nil nil (car my-org-src-languages))))
  (hot-expand "<s" language)
  (when (bound-and-true-p meow-normal-mode)
    (meow-insert)))

(use-package org-modern
  :autoload org-modern-mode org-modern-agenda
  :custom
  (org-modern-table nil)
  (org-modern-star '("◉" "○" "◆" "◇" "▸"))
  :hook ((org-mode . (lambda ()
                       "Display org modern looks in GUI."
                       (if (display-graphic-p)
                           (org-modern-mode 1)
                         (org-modern-mode -1))))
         (org-agenda-finalize . (lambda ()
                                  "Display org modern agenda in GUI."
                                  (when (display-graphic-p)
                                    (org-modern-agenda))))))

(use-package org-appear
  :custom
  (org-appear-autoentities t)
  (org-appear-autokeywords t)
  (org-appear-autolinks t)
  (org-appear-autosubmarkers t)
  (org-appear-inside-latex t)
  (org-appear-manual-linger t)
  (org-appear-delay 0.5)
  :hook (org-mode . org-appear-mode))

;; Rich text clipboard
(use-package org-rich-yank
  :after org
  :bind (:map org-mode-map
         ("C-M-y" . org-rich-yank)))

;; Table of contents
(use-package toc-org
  :hook (org-mode . toc-org-mode))

;; Preview
(use-package org-preview-html
  :after org
  :bind (:map org-mode-map
         ("C-c C-h" . org-preview-html-mode))
  :init (when (xwidget-workable-p)
          (setq org-preview-html-viewer 'xwidget)))

;; Presentation
(use-package dslide
  :after org
  :bind (:map org-mode-map
         ("s-<f7>" . dslide-deck-start)))
(use-package org-roam
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n j" . org-roam-dailies-capture-today))
  :custom
  (org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-graph-viewer #'centaur-browse-url)
  :init
  (setq org-roam-directory (file-truename my-org-directory)
        org-roam-db-location (my-state-file "org-roam.db")
        org-roam-capture-templates
        '(("d" "Note" plain "%?"
           :target (file+head "notes/${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)))
  :config
  (add-to-list 'org-agenda-files org-roam-directory)
  (org-roam-db-autosync-mode 1))

(use-package org-roam-ui
  :bind ("C-c n u" . org-roam-ui-mode)
  :init (setq org-roam-ui-browser-function #'centaur-browse-url))
(use-package org-roam-dailies
  :after org-roam
  :commands (org-roam-dailies-capture-today org-roam-dailies-goto-today)
  :custom
  (org-roam-dailies-directory "journal/")
  (org-roam-dailies-capture-templates
   '(("d" "Daily journal" entry "* %<%H:%M> %?"
      :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")))))

(defun my-org-open ()
  "Browse the notes directory."
  (interactive)
  (dirvish my-org-directory))
(defun my-org-journal ()
  "Open today's linked journal entry."
  (interactive)
  (require 'org-roam)
  (require 'org-roam-dailies)
  (org-roam-dailies-goto-today))

(defun my-open-keybindings ()
  "Open the key reference in a new pane to the right."
  (interactive)
  (let ((file my-keybindings-file))
    (unless (file-readable-p file)
      (user-error "Key reference is missing: %s" file))
    (select-window (split-window-right))
    (find-file file)
    (when (bound-and-true-p diff-hl-mode) (diff-hl-mode -1))
    (when (bound-and-true-p blamer-mode) (blamer-mode -1))
    (setq-local display-line-numbers nil
                org-fold-show-context-detail '((link-search . local)
                                               (default . ancestors)))
    (visual-line-mode 1)
    (dolist (face '(org-code org-verbatim))
      (face-remap-set-base
       face :inherit 'font-lock-constant-face
       :background (face-background 'corfu-default nil t)))
    (face-remap-set-base 'org-table 'default)
    (face-remap-set-base 'org-document-title 'org-level-1 :height 1.0)
    (goto-char (point-min))))

;; Markdown (Centaur): markdown-ts-mode for .md files, gfm-mode for READMEs.
(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode))
  :init
  (setq markdown-enable-wiki-links t
        markdown-italic-underscore t
        markdown-asymmetric-header t
        markdown-make-gfm-checkboxes-buttons t
        markdown-gfm-uppercase-checkbox t
        markdown-fontify-code-blocks-natively t
        markdown-gfm-additional-languages "Mermaid"
        markdown-command '("cmark-gfm" "--unsafe" "--extension" "table"
                           "--extension" "strikethrough" "--extension" "autolink"
                           "--extension" "tasklist"))
  :config
  (add-to-list 'markdown-code-lang-modes '("mermaid" . mermaid-ts-mode))

  ;; Preview Mermaid diagrams (C-c M)
  (use-package markdown-mermaid
    :bind (:map markdown-mode-map
           ("C-c M" . markdown-mermaid-preview)))

  (with-no-warnings
    ;; Use `which-key' instead
    (advice-add #'markdown--command-map-prompt :override #'ignore)
    (advice-add #'markdown--style-map-prompt   :override #'ignore)

    ;; Preview with built-in webkit
    (defun my/markdown-export-and-preview ()
      "Preview with `xwidget' if applicable, otherwise with the default browser."
      (centaur-browse-url-of-file (markdown-export)))
    (advice-add #'markdown-export-and-preview :override #'my/markdown-export-and-preview))

  ;; Table of contents
  (use-package markdown-toc
    :bind (:map markdown-mode-command-map
           ("r" . markdown-toc-generate-or-refresh-toc))
    :hook (markdown-mode . markdown-toc-mode)
    :init (setq markdown-toc-indentation-space 2
                markdown-toc-header-toc-title "\n## Table of Contents"
                markdown-toc-user-toc-structure-manipulation-fn 'cdr)
    :config
    (with-no-warnings
      (define-advice markdown-toc-generate-toc (:around (fn &rest args) lsp)
        "Generate or refresh toc after disabling lsp."
        (cond
         ((bound-and-true-p eglot--manage-mode)
          (eglot--manage-mode -1)
          (apply fn args)
          (eglot--manage-mode 1))
         (t
          (apply fn args)))))))

(use-package markdown-ts-mode
  :ensure nil
  :mode ("\\.md\\'" "\\.mdx\\'" "\\.markdown\\'")
  :custom (markdown-ts-ellipsis " ⌄")
  :config (require 'markdown-ts-mode-x))

;; GitHub-flavoured preview served by grip (C-c C-g)
(use-package grip-mode
  :commands grip-mode
  :init
  (with-eval-after-load 'markdown-mode
    (bind-key "C-g" #'grip-mode markdown-mode-command-map))
  (with-eval-after-load 'markdown-ts-mode
    (bind-key "C-c C-g" #'grip-mode markdown-ts-mode-map))
  (with-eval-after-load 'org
    (bind-key "C-c C-g" #'grip-mode org-mode-map)))

;; This config's own preview: the rendered page in a reading pane beside
;; the source (C-c C-c v, SPC o m); g in the pane refreshes it.
(defvar-local my-markdown-preview-source nil)

(defun my-markdown-render-code (dom)
  "Render DOM as code with terminal-visible styling."
  (shr-fontize-dom dom 'org-code))

(defun my-markdown-render-code-block (dom)
  "Render DOM as a code block, preserving whitespace."
  (let ((start (point)))
    (shr-tag-pre dom)
    (shr-add-font start (point) 'org-block)))

(defun my-markdown-preview ()
  "Render Markdown in a reading pane, or refresh its existing preview."
  (interactive)
  (require 'eww)
  (let* ((source (or my-markdown-preview-source (current-buffer)))
         (html (generate-new-buffer " *Markdown HTML*"))
         preview)
    (unwind-protect
        (with-current-buffer source
          (unless (derived-mode-p 'markdown-mode 'markdown-ts-mode)
            (user-error "Open a Markdown buffer first"))
          (let* ((name (buffer-name))
                 (directory default-directory)
                 (url (url-encode-url (concat "file://" (or buffer-file-name directory)))))
            ;; markdown-mode renders it, whichever mode is editing it.
            (let ((text (save-restriction (widen) (buffer-string))))
              (with-temp-buffer
                (insert text)
                (delay-mode-hooks (markdown-mode))
                (let ((mark-active nil))
                  (markdown-standalone (buffer-name html) name))))
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
                (define-key map (kbd "g") #'my-markdown-preview)
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


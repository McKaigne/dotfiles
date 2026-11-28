;;; notes.el -*- lexical-binding: t -*-

(setq org-directory (directory-file-name nixmacs-org-directory)
      org-roam-directory (expand-file-name "roam" nixmacs-org-directory))

(defun nixmacs-org-file (name)
  "Return the path of NAME inside the notes directory."
  (expand-file-name name org-directory))

(defun nixmacs-journal-file ()
  "Return today's journal file."
  (nixmacs-org-file (format-time-string "journal/%Y-%m-%d.org")))

(use-package org
  :defer t
  :custom
  (org-default-notes-file (nixmacs-org-file "tasks.org"))
  (org-agenda-files (list (nixmacs-org-file "tasks.org")
                          (nixmacs-org-file "journal")))
  (org-id-locations-file (nixmacs-state-file "org-id-locations"))
  (org-persist-directory (nixmacs-state-file "org-persist/"))
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-capture-templates
   `(("t" "Todo" entry
      (file+headline ,(nixmacs-org-file "tasks.org") "Inbox")
      "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
     ("j" "Journal" entry (file+olp+datetree nixmacs-journal-file)
      "* %<%H:%M> %?\n")))
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((emacs-lisp . t) (python . t) (C . t) (shell . t)))
  (setq org-confirm-babel-evaluate #'nixmacs-org-confirm-babel-evaluate))

(defun nixmacs-org-confirm-babel-evaluate (_language _body)
  "Ask before running code blocks outside the notes directory."
  (not (and buffer-file-name
            (not (file-remote-p buffer-file-name))
            (file-in-directory-p (file-truename buffer-file-name)
                                 (file-truename org-directory)))))

(defvar nixmacs-org-heading-heights '(1.3 1.18 1.08 1.0 1.0 1.0 1.0 1.0))

(defun nixmacs-org-faces (&rest _)
  "Give headings, the title and meta lines their sizes and weights."
  (when (featurep 'org)
    (cl-loop for height in nixmacs-org-heading-heights
             for level from 1
             do (set-face-attribute (intern (format "org-level-%d" level)) nil
                                    :height height :weight 'bold))
    (set-face-attribute 'org-document-title nil :height 1.6 :weight 'heavy)
    (set-face-attribute 'org-document-info nil :height 1.1 :inherit 'shadow)
    (set-face-attribute 'org-ellipsis nil :inherit 'shadow :foreground 'unspecified
                        :underline nil :weight 'normal)
    (dolist (face '(org-meta-line org-drawer org-special-keyword org-property-value
                    org-block-begin-line org-block-end-line))
      (set-face-attribute face nil :inherit 'shadow :foreground 'unspecified
                          :background 'unspecified :slant 'normal :height 0.9))
    (set-face-attribute 'org-headline-done nil :inherit 'shadow
                        :foreground 'unspecified :strike-through nil)
    (set-face-attribute 'org-checkbox-statistics-todo nil :inherit 'shadow)
    (set-face-attribute 'org-quote nil :slant 'italic :inherit 'org-block)
    (set-face-attribute 'org-agenda-structure nil :height 1.18 :weight 'bold)
    (set-face-attribute 'org-agenda-date-today nil :height 1.08 :weight 'heavy
                        :slant 'normal)))

(add-hook 'enable-theme-functions #'nixmacs-org-faces 95)

(with-eval-after-load 'org
  (setq org-startup-indented nil
        org-startup-with-inline-images t
        org-image-actual-width '(560)
        org-hide-emphasis-markers t
        org-pretty-entities t
        org-pretty-entities-include-sub-superscripts nil
        org-use-sub-superscripts '{}
        org-ellipsis " …"
        org-tags-column 0
        org-auto-align-tags nil
        org-fontify-done-headline t
        org-fontify-todo-headline nil
        org-fontify-quote-and-verse-blocks t
        org-fontify-whole-heading-line nil
        org-src-fontify-natively t
        org-highlight-latex-and-related '(native))
  (nixmacs-org-faces))

(defun nixmacs-org-tag-space ()
  "Return properties that push the matched heading's tags to the right edge."
  (let* ((level (- (match-end 1) (match-beginning 1)))
         (height (or (nth (1- level) nixmacs-org-heading-heights) 1.0))
         (width (+ 2 (string-width org-ellipsis)
                   (* height (1+ (string-width (match-string 3)))))))
    `(face nil display (space :align-to (- right ,width)))))

(defun nixmacs-org-setup-buffer ()
  "Set up an Org buffer for reading and writing prose."
  (setq-local line-spacing 0.15)
  (font-lock-add-keywords
   nil
   `((,(concat "^\\(\\*+\\) .*?[^ ]\\( +\\)\\(:\\(?:" org-tag-re ":\\)+\\)[ \t]*$")
      (2 (nixmacs-org-tag-space) prepend)))
   t))

(add-hook 'org-mode-hook #'nixmacs-org-setup-buffer)

(use-package org-modern
  :after org
  :demand t
  :custom
  (org-modern-star 'fold)
  (org-modern-fold-stars '(("▸" . "▾") ("▹" . "▿")))
  (org-modern-hide-stars 'leading)
  (org-modern-list '((?- . "•") (?+ . "◦") (?* . "▪")))
  (org-modern-checkbox '((?X . "✔") (?- . "◐") (?\s . "○")))
  (org-modern-block-fringe 2)
  (org-modern-keyword '(("title" . "") (t . t)))
  (org-modern-horizontal-rule (make-string 48 ?─))
  (org-modern-label-border 0.25)
  (org-modern-progress 10)
  (org-modern-table-vertical 1)
  (org-modern-todo-faces
   '(("TODO" :inherit (nixmacs-label-todo org-modern-todo))
     ("NEXT" :inherit (nixmacs-label-next org-modern-todo))
     ("WAIT" :inherit (nixmacs-label-wait org-modern-todo))
     ("DONE" :inherit org-modern-done)
     ("CANCELLED" :inherit org-modern-done :strike-through t)))
  (org-modern-priority-faces
   '((?A :inherit (nixmacs-label-fix org-modern-priority))
     (?B :inherit (nixmacs-label-hack org-modern-priority))
     (?C :inherit (nixmacs-label-note org-modern-priority))))
  :config
  (global-org-modern-mode 1))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autoemphasis t)
  (org-appear-autoentities t)
  (org-appear-inside-latex t))

(use-package org-tidy
  :hook (org-mode . org-tidy-mode)
  :custom
  (org-tidy-properties-inline-symbol "⋯")
  (org-tidy-general-drawer-flag nil))

(use-package olivetti
  :hook (org-mode . olivetti-mode)
  :custom
  (olivetti-body-width 84)
  (olivetti-minimum-body-width 60)
  (olivetti-recall-visual-line-mode-entry-state nil))

(with-eval-after-load 'org-agenda
  (setq org-agenda-tags-column 0
        org-agenda-block-separator ?─
        org-agenda-start-with-log-mode nil
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-include-deadlines t
        org-agenda-compact-blocks nil
        org-agenda-time-grid '((daily today require-timed)
                               (800 1000 1200 1400 1600 1800 2000)
                               " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string "◀── now ─────────────────────────────"
        org-agenda-prefix-format '((agenda . "  %?-12t% s")
                                   (todo . "  %-10:c ")
                                   (tags . "  %-10:c ")
                                   (search . "  %-10:c "))
        org-agenda-scheduled-leaders '("" "%2d× ")
        org-agenda-deadline-leaders '("⚑ " "in %2dd " "%2dd ago ")))

(add-hook 'org-agenda-finalize-hook #'hl-line-mode)

(use-package org-super-agenda
  :after org-agenda
  :demand t
  :custom
  (org-super-agenda-header-separator "")
  (org-super-agenda-header-prefix "  ")
  (org-super-agenda-groups
   '((:name "Today" :time-grid t :scheduled today :deadline today)
     (:name "Overdue" :deadline past :scheduled past)
     (:name "Next" :todo "NEXT")
     (:name "Waiting" :todo "WAIT")
     (:name "Inbox" :tag "inbox")
     (:auto-category t)))
  :config
  (set-face-attribute 'org-super-agenda-header nil :inherit 'org-level-2)
  (org-super-agenda-mode 1))

(use-package org-roam
  :defer t
  :custom
  (org-roam-db-location (nixmacs-state-file "org-roam.db"))
  (org-roam-node-display-template
   (concat "${title:*} " (propertize "${tags:24}" 'face 'org-tag)))
  (org-roam-capture-templates
   '(("f" "Fleeting: a quick thought to process later" plain "%?"
      :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :fleeting:\n")
      :unnarrowed t)
     ("l" "Literature: notes on a source" plain
      "Source: %^{Source}\n\n%?"
      :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :literature:\n")
      :unnarrowed t)
     ("p" "Permanent: one atomic idea, in your own words" plain "%?"
      :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :permanent:\n")
      :unnarrowed t)))
  :config
  (make-directory org-roam-directory t)
  (org-roam-db-autosync-mode 1))

(use-package consult-org-roam
  :after org-roam
  :demand t
  :custom
  (consult-org-roam-grep-func #'consult-ripgrep)
  :config
  (consult-org-roam-mode 1))

(defun nixmacs-org-journal ()
  "Add an entry to today's journal."
  (interactive)
  (org-capture nil "j"))

(defun nixmacs-org-toggle-last-clock ()
  "Clock out of the running clock, or clock back in to the last one."
  (interactive)
  (require 'org-clock)
  (if (org-clocking-p) (org-clock-out) (org-clock-in-last)))

(defun nixmacs-notes-find-file ()
  "Find a file in the notes directory."
  (interactive)
  (consult-fd org-directory))

(defun nixmacs-notes-search ()
  "Search the notes directory."
  (interactive)
  (consult-ripgrep org-directory))

(defun nixmacs-notes-search-symbol ()
  "Search the notes directory for the symbol at point."
  (interactive)
  (consult-ripgrep org-directory (thing-at-point 'symbol t)))

(defun nixmacs-notes-browse ()
  "Browse the notes directory."
  (interactive)
  (dired org-directory))

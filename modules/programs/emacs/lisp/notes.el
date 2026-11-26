;;; notes.el -*- lexical-binding: t -*-

(setq org-directory (directory-file-name my-org-directory)
      org-roam-directory (expand-file-name "roam" my-org-directory))

(defun my-journal-file ()
  "Return today's journal file."
  (expand-file-name (format-time-string "journal/%Y-%m-%d.org") org-directory))

(use-package org
  :defer t
  :custom
  (org-default-notes-file (expand-file-name "tasks.org" org-directory))
  (org-agenda-files (list (expand-file-name "tasks.org" org-directory)
                          (expand-file-name "journal" org-directory)))
  (org-id-locations-file (my-state-file "org-id-locations"))
  (org-persist-directory (my-state-file "org-persist/"))
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@)" "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-agenda-tags-column 0)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-startup-indented nil)
  (org-ellipsis "…")
  (org-capture-templates
   `(("t" "Todo" entry
      (file+headline ,(expand-file-name "tasks.org" org-directory) "Inbox")
      "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
     ("j" "Journal" entry (file+olp+datetree my-journal-file)
      "* %<%H:%M> %?\n")))
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((emacs-lisp . t) (python . t) (C . t) (shell . t)))
  (setq org-confirm-babel-evaluate #'my-org-confirm-babel-evaluate))

(defun my-org-confirm-babel-evaluate (_language _body)
  "Ask before running code blocks outside the notes directory."
  (not (and buffer-file-name
            (not (file-remote-p buffer-file-name))
            (file-in-directory-p (file-truename buffer-file-name)
                                 (file-truename org-directory)))))

(use-package org-modern
  :after org
  :demand t
  :config
  (global-org-modern-mode 1))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :custom
  (org-appear-autolinks t)
  (org-appear-autoemphasis t))

(use-package olivetti
  :hook (org-mode . olivetti-mode)
  :custom
  (olivetti-body-width 100))

(use-package org-super-agenda
  :after org-agenda
  :demand t
  :config
  (org-super-agenda-mode 1)
  :custom
  (org-super-agenda-groups
   '((:name "Today" :time-grid t :scheduled today :deadline today)
     (:name "Overdue" :deadline past :scheduled past)
     (:name "Next" :todo "NEXT")
     (:name "Waiting" :todo "WAIT")
     (:name "Inbox" :tag "inbox")
     (:auto-category t))))

(use-package org-roam
  :defer t
  :custom
  (org-roam-db-location (my-state-file "org-roam.db"))
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

(defun my-org-journal ()
  "Add an entry to today's journal."
  (interactive)
  (org-capture nil "j"))

(defun my-org-toggle-last-clock ()
  "Clock out of the running clock, or clock back in to the last one."
  (interactive)
  (require 'org-clock)
  (if (org-clocking-p) (org-clock-out) (org-clock-in-last)))

(defun my-notes-find-file ()
  "Find a file in the notes directory."
  (interactive)
  (consult-fd org-directory))

(defun my-notes-search ()
  "Search the notes directory."
  (interactive)
  (consult-ripgrep org-directory))

(defun my-notes-search-symbol ()
  "Search the notes directory for the symbol at point."
  (interactive)
  (consult-ripgrep org-directory (thing-at-point 'symbol t)))

(defun my-notes-browse ()
  "Browse the notes directory."
  (interactive)
  (dirvish org-directory))

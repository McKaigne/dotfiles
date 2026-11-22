;;; keys.el -*- lexical-binding: t -*-

;; Keys live in Emacs's own keymaps, reached through meow's keypad as meow
;; intends (editing.el): SPC x … is C-x …, SPC h … is C-h …, SPC c … is
;; C-c …, SPC m … is M-…, SPC g … is C-M-…, and SPC <other letter> is the
;; leader, C-c <letter> (the keys Emacs reserves for the user). So files are
;; SPC x f / SPC x s, buffers SPC x b, windows SPC x 2 / 3 / 0 / 1 / o,
;; projects SPC x p …, Magit SPC x g, help SPC h ….  Nothing parallel to
;; learn: every key here is the real Emacs binding without the chord.

;; Consult's drop-in upgrades of Emacs's own commands.
(keymap-global-set "<remap> <switch-to-buffer>" #'consult-buffer)
(keymap-global-set "<remap> <switch-to-buffer-other-window>" #'consult-buffer-other-window)
(keymap-global-set "<remap> <project-switch-to-buffer>" #'consult-project-buffer)
(keymap-global-set "<remap> <project-find-regexp>" #'consult-ripgrep)
(keymap-global-set "<remap> <goto-line>" #'consult-goto-line)
(keymap-global-set "<remap> <imenu>" #'consult-imenu)
(keymap-global-set "<remap> <bookmark-jump>" #'consult-bookmark)
(keymap-global-set "<remap> <recentf-open>" #'consult-recent-file)
(keymap-global-set "<remap> <list-buffers>" #'ibuffer)
(keymap-global-set "M-s l" #'consult-line)
(keymap-global-set "M-s r" #'consult-ripgrep)
(keymap-global-set "M-s f" #'consult-fd)
(keymap-global-set "M-g e" #'consult-compile-error)
(keymap-global-set "M-g f" #'consult-flymake)

;; Everything else gets a key too. Meow's docs add your own commands with
;; meow-leader-define-key: they land on C-c <letter> (the keys Emacs leaves
;; to the user), reached as SPC <letter>; meow's own keys stay as shipped.
;; c, x, h, m and g are keypad prefixes, so never leader letters.
;; Each key carries a label, so the keypad hints read as words.
(defvar-keymap my-lsp-map
  :doc "Language server (eglot)."
  "a" '("code actions" . eglot-code-actions)
  "r" '("rename" . eglot-rename)
  "f" '("format" . apheleia-format-buffer)
  "o" '("organize imports" . eglot-code-action-organize-imports)
  "d" '("declaration" . eglot-find-declaration)
  "i" '("implementation" . eglot-find-implementation)
  "t" '("type definition" . eglot-find-typeDefinition)
  "e" '("errors" . consult-flymake)
  "s" '("start server" . eglot)
  "q" '("stop server" . eglot-shutdown))

(defvar-keymap my-notes-map
  :doc "Notes and Org."
  "f" '("find note" . org-roam-node-find)
  "i" '("insert link" . org-roam-node-insert)
  "b" '("backlinks" . org-roam-buffer-toggle)
  "j" '("journal" . my-org-journal)
  "c" '("capture" . org-capture)
  "a" '("agenda" . org-agenda)
  "l" '("store link" . org-store-link))

(meow-leader-define-key
 (cons "l" (cons "LSP" my-lsp-map))
 (cons "n" (cons "notes" my-notes-map))
 '("t" . ("terminal" . vterm-toggle-cd))
 '("o" . ("file tree" . treemacs))
 '("d" . ("dashboard" . my-dashboard-open))
 '("b" . ("blame line" . blamer-show-commit-info))
 '("k" . ("key guide" . my-open-keybindings)))
(with-eval-after-load 'envrc
  (meow-leader-define-key (cons "e" (cons "direnv" envrc-command-map))))

;; In Emacs's own maps where one fits.
(keymap-set project-prefix-map "t" #'vterm-toggle-cd)
(keymap-set project-prefix-map "C" #'recompile)
(keymap-set project-prefix-map "E" #'my-project-environment-setup)
(with-eval-after-load 'flymake
  (keymap-set flymake-mode-map "M-n" #'flymake-goto-next-error)
  (keymap-set flymake-mode-map "M-p" #'flymake-goto-prev-error))
(with-eval-after-load 'markdown-mode
  (keymap-set markdown-mode-map "C-c C-c v" #'my-markdown-preview))

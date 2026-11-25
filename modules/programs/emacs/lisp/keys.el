;;; keys.el -*- lexical-binding: t -*-

(defun my-define-keys (map &rest bindings)
  "Bind BINDINGS in MAP; each is (KEY LABEL DEFINITION)."
  (dolist (binding bindings map)
    (pcase-let ((`(,key ,label ,definition) binding))
      (when (and (symbolp definition) (not (fboundp definition))
                 (boundp definition) (keymapp (symbol-value definition)))
        (setq definition (symbol-value definition)))
      (define-key map (kbd key) (cons label definition)))))

(defmacro my-define-menu (name &rest bindings)
  "Define NAME as a keymap holding BINDINGS, each (KEY LABEL DEFINITION)."
  `(progn
     (defvar ,name (make-sparse-keymap))
     (my-define-keys ,name ,@(mapcar (lambda (b) `'(,@b)) bindings))))

(defun my-code-actions (beg &optional end)
  "Pick a code action from a list, even when only one applies."
  (interactive (eglot--code-action-bounds))
  (eglot-server-capable-or-lose :codeActionProvider)
  (eglot--read-execute-code-action (eglot-code-actions beg end)
                                   (eglot--current-server-or-lose)))

(defun my-search-project-symbol ()
  "Search the project for the symbol at point."
  (interactive)
  (consult-ripgrep nil (thing-at-point 'symbol t)))

(defun my-search-directory ()
  "Search the current directory."
  (interactive)
  (consult-ripgrep default-directory))

(defun my-search-other-directory ()
  "Search a directory chosen from a prompt."
  (interactive)
  (consult-ripgrep (read-directory-name "Search directory: ")))

(defun my-search-config ()
  "Search this Emacs config's source."
  (interactive)
  (consult-ripgrep my-config-source))

(defun my-search-other-project ()
  "Search a project chosen from a prompt."
  (interactive)
  (consult-ripgrep (project-prompt-project-dir)))

(defun my-search-buffer-symbol ()
  "Search this buffer for the symbol at point."
  (interactive)
  (consult-line (thing-at-point 'symbol t)))

(defun my-toggle-narrow ()
  "Widen a narrowed buffer, or narrow to the region or the defun."
  (interactive)
  (cond ((buffer-narrowed-p) (widen))
        ((region-active-p) (narrow-to-region (region-beginning) (region-end)))
        (t (narrow-to-defun))))

(defun my-kill-all-buffers ()
  "Kill every buffer and show the dashboard."
  (interactive)
  (when (yes-or-no-p "Kill all buffers? ")
    (save-some-buffers)
    (dolist (buffer (buffer-list))
      (unless (string-prefix-p " " (buffer-name buffer))
        (kill-buffer buffer)))
    (my-open-dashboard)))

(defun my-kill-other-buffers ()
  "Kill every buffer except this one."
  (interactive)
  (when (yes-or-no-p "Kill all other buffers? ")
    (dolist (buffer (buffer-list))
      (unless (or (eq buffer (current-buffer))
                  (string-prefix-p " " (buffer-name buffer)))
        (kill-buffer buffer)))))

(defun my-new-buffer ()
  "Open a new empty buffer."
  (interactive)
  (switch-to-buffer (generate-new-buffer "untitled")))

(defun my-save-all-buffers ()
  "Save every modified file buffer."
  (interactive)
  (save-some-buffers t))

(defun my-copy-buffer ()
  "Copy the whole buffer."
  (interactive)
  (kill-new (buffer-substring-no-properties (point-min) (point-max)))
  (message "Copied the buffer"))

(defun my-sudo-file-name (file)
  "Return FILE opened through sudo."
  (concat "/sudo::" (expand-file-name file)))

(defun my-sudo-save-buffer ()
  "Save this buffer's text to its file as root."
  (interactive)
  (unless buffer-file-name (user-error "This buffer isn't visiting a file"))
  (write-region nil nil (my-sudo-file-name buffer-file-name))
  (set-buffer-modified-p nil))

(defun my-sudo-find-file (file)
  "Open FILE as root."
  (interactive "FSudo find file: ")
  (find-file (my-sudo-file-name file)))

(defun my-sudo-this-file ()
  "Open this buffer's file again as root."
  (interactive)
  (unless buffer-file-name (user-error "This buffer isn't visiting a file"))
  (find-alternate-file (my-sudo-file-name buffer-file-name)))

(defun my-copy-this-file (new)
  "Copy this buffer's file to NEW and open the copy."
  (interactive (list (read-file-name "Copy to: ")))
  (unless buffer-file-name (user-error "This buffer isn't visiting a file"))
  (copy-file buffer-file-name new 1)
  (find-file new))

(defun my-delete-this-file ()
  "Delete this buffer's file and kill the buffer."
  (interactive)
  (let ((file (or buffer-file-name (user-error "This buffer isn't visiting a file"))))
    (when (yes-or-no-p (format "Delete %s? " (abbreviate-file-name file)))
      (delete-file file t)
      (kill-buffer))))

(defun my-find-in-emacs-directory ()
  "Find a file in the deployed Emacs directory."
  (interactive)
  (consult-fd user-emacs-directory))

(defun my-browse-emacs-directory ()
  "Browse the deployed Emacs directory."
  (interactive)
  (dired user-emacs-directory))

(defun my-find-in-config ()
  "Find a file in this Emacs config's source."
  (interactive)
  (consult-fd my-config-source))

(defun my-browse-config ()
  "Browse this Emacs config's source."
  (interactive)
  (dired my-config-source))

(defun my-find-file-here ()
  "Find a file under the current directory."
  (interactive)
  (consult-fd default-directory))

(defun my-copy-file-path ()
  "Copy this buffer's file path."
  (interactive)
  (let ((path (or buffer-file-name default-directory)))
    (kill-new (abbreviate-file-name path))
    (message "Copied %s" (abbreviate-file-name path))))

(defun my-copy-project-file-path ()
  "Copy this buffer's file path relative to the project."
  (interactive)
  (let* ((path (or buffer-file-name default-directory))
         (project (project-current))
         (relative (if project (file-relative-name path (project-root project)) path)))
    (kill-new relative)
    (message "Copied %s" relative)))

(defun my-insert-file-name ()
  "Insert this buffer's file name."
  (interactive)
  (insert (file-name-nondirectory (or buffer-file-name (buffer-name)))))

(defun my-insert-file-path ()
  "Insert this buffer's full file path."
  (interactive)
  (insert (abbreviate-file-name (or buffer-file-name default-directory))))

(defun my-insert-shell-output (command)
  "Insert the output of the shell COMMAND."
  (interactive (list (read-shell-command "Insert output of: ")))
  (insert (string-trim-right (shell-command-to-string command))))

(defun my-eval-buffer-or-region ()
  "Evaluate the region, or the whole buffer, as Emacs Lisp."
  (interactive)
  (if (region-active-p)
      (eval-region (region-beginning) (region-end))
    (eval-buffer))
  (message "Evaluated"))

(defun my-project-edit-dir-locals ()
  "Open the project's .dir-locals.el."
  (interactive)
  (find-file (expand-file-name ".dir-locals.el" (project-root (project-current t)))))

(defun my-project-find-file-other ()
  "Find a file in a project chosen from a prompt."
  (interactive)
  (let ((default-directory (project-prompt-project-dir)))
    (call-interactively #'project-find-file)))

(defun my-project-save-buffers ()
  "Save every modified buffer in the current project."
  (interactive)
  (let ((root (project-root (project-current t))))
    (save-some-buffers t (lambda ()
                           (and buffer-file-name
                                (file-in-directory-p buffer-file-name root))))))

(defun my-restart-daemon ()
  "Save, then restart the Emacs daemon through systemd."
  (interactive)
  (save-some-buffers)
  (when (yes-or-no-p "Restart the Emacs daemon? Every frame closes. ")
    (call-process "systemctl" nil 0 nil "--user" "restart" "emacs.service")))

(defun my-quit-without-saving ()
  "Stop Emacs without saving, after asking."
  (interactive)
  (when (yes-or-no-p "Quit Emacs without saving? ")
    (kill-emacs 1)))

(defun my-window-previous ()
  "Select the previous window."
  (interactive)
  (other-window -1))

(defun my-window-last-used ()
  "Select the window used before this one."
  (interactive)
  (if-let* ((window (get-mru-window nil t t)))
      (select-window window)
    (user-error "No other window")))

(defun my-window-top-left ()
  "Select the top-left window."
  (interactive)
  (select-window (frame-first-window)))

(defun my-window-bottom-right ()
  "Select the bottom-right window."
  (interactive)
  (select-window (previous-window (frame-first-window) 'nomini)))

(defun my-window-exchange ()
  "Swap this window with the next one."
  (interactive)
  (window-swap-states nil (next-window nil 'nomini)))

(defun my-window-split-below-follow ()
  "Split below and select the new window."
  (interactive)
  (select-window (split-window-below)))

(defun my-window-split-right-follow ()
  "Split right and select the new window."
  (interactive)
  (select-window (split-window-right)))

(defun my-window-new ()
  "Split below and show a new empty buffer there."
  (interactive)
  (select-window (split-window-below))
  (switch-to-buffer (generate-new-buffer "untitled")))

(defun my-window-quit ()
  "Close this window, or the frame when it is the last ordinary one."
  (interactive)
  (if (or (one-window-p) (eq (selected-window) (window-main-window)))
      (delete-frame)
    (delete-window)))

(defun my-window-full-height ()
  "Make this window as tall as it can be."
  (interactive)
  (window-resize nil (window-max-delta nil nil) nil))

(defun my-window-full-width ()
  "Make this window as wide as it can be."
  (interactive)
  (window-resize nil (window-max-delta nil t) t))

(defvar-keymap my-zoom-repeat-map
  :repeat t
  "+" #'text-scale-increase
  "=" #'text-scale-increase
  "-" #'text-scale-decrease)

(my-define-menu my-buffer-map
  ("-" "toggle narrowing" my-toggle-narrow)
  ("b" "switch buffer" consult-buffer)
  ("c" "clone buffer" clone-indirect-buffer)
  ("C" "clone buffer other window" clone-indirect-buffer-other-window)
  ("d" "kill buffer" kill-current-buffer)
  ("i" "ibuffer" ibuffer)
  ("K" "kill all buffers" my-kill-all-buffers)
  ("l" "last buffer" meow-last-buffer)
  ("m" "set bookmark" bookmark-set)
  ("M" "delete bookmark" bookmark-delete)
  ("n" "next buffer" next-buffer)
  ("N" "new empty buffer" my-new-buffer)
  ("O" "kill other buffers" my-kill-other-buffers)
  ("p" "previous buffer" previous-buffer)
  ("r" "revert buffer" revert-buffer)
  ("R" "rename buffer" rename-buffer)
  ("s" "save buffer" basic-save-buffer)
  ("S" "save all buffers" my-save-all-buffers)
  ("u" "save buffer as root" my-sudo-save-buffer)
  ("x" "scratch buffer" scratch-buffer)
  ("y" "copy buffer" my-copy-buffer)
  ("z" "bury buffer" bury-buffer)
  ("Z" "kill old buffers" clean-buffer-list))

(my-define-menu my-docs-map
  ("d" "documentation at point" eldoc-box-help-at-point)
  ("f" "describe function" helpful-callable)
  ("v" "describe variable" helpful-variable)
  ("k" "describe key" helpful-key))

(my-define-menu my-errors-map
  ("l" "buffer errors" flymake-show-buffer-diagnostics)
  ("L" "project errors" flymake-show-project-diagnostics)
  ("n" "next error" flymake-goto-next-error)
  ("p" "previous error" flymake-goto-prev-error))

(my-define-menu my-file-map
  ("c" "open project editorconfig" editorconfig-find-current-editorconfig)
  ("C" "copy this file" my-copy-this-file)
  ("d" "find directory" dired)
  ("D" "delete this file" my-delete-this-file)
  ("e" "find file in emacs.d" my-find-in-emacs-directory)
  ("E" "browse emacs.d" my-browse-emacs-directory)
  ("f" "find file" find-file)
  ("F" "find file from here" my-find-file-here)
  ("l" "locate file" consult-locate)
  ("p" "find file in config" my-find-in-config)
  ("P" "browse config" my-browse-config)
  ("r" "recent files" consult-recent-file)
  ("R" "rename/move file" rename-visited-file)
  ("s" "save file" save-buffer)
  ("S" "save file as" write-file)
  ("u" "sudo find file" my-sudo-find-file)
  ("U" "sudo this file" my-sudo-this-file)
  ("y" "copy file path" my-copy-file-path)
  ("Y" "copy project file path" my-copy-project-file-path))

(my-define-menu my-insert-map
  ("e" "emoji" emoji-search)
  ("f" "file name" my-insert-file-name)
  ("F" "file path" my-insert-file-path)
  ("p" "shell command output" my-insert-shell-output)
  ("r" "from register" consult-register)
  ("s" "snippet" yas-insert-snippet)
  ("u" "unicode" insert-char)
  ("y" "from kill ring" consult-yank-pop))

(my-define-menu my-macro-map
  ("s" "start macro" kmacro-start-macro)
  ("e" "stop macro" meow-end-kmacro)
  ("r" "run macro" kmacro-call-macro)
  ("n" "name macro" kmacro-name-last-macro))

(my-define-menu my-code-map
  ("b" "go back" xref-go-back)
  ("c" "compile" compile)
  ("C" "recompile" recompile)
  ("d" "find definition" xref-find-definitions)
  ("D" "find references" xref-find-references)
  ("e" "evaluate buffer/region" my-eval-buffer-or-region)
  ("f" "format buffer" apheleia-format-buffer)
  ("i" "find implementations" eglot-find-implementation)
  ("j" "find workspace symbol" xref-find-apropos)
  ("o" "organize imports" eglot-code-action-organize-imports)
  ("r" "rename" eglot-rename)
  ("t" "find type definition" eglot-find-typeDefinition)
  ("w" "delete trailing whitespace" delete-trailing-whitespace))

(my-define-menu my-roam-map
  ("a" "random node" org-roam-node-random)
  ("b" "backlinks" consult-org-roam-backlinks)
  ("f" "find node" org-roam-node-find)
  ("F" "find ref" org-roam-ref-find)
  ("i" "insert node" org-roam-node-insert)
  ("l" "forward links" consult-org-roam-forward-links)
  ("n" "capture to node" org-roam-capture)
  ("r" "toggle roam buffer" org-roam-buffer-toggle)
  ("R" "launch roam buffer" org-roam-buffer-display-dedicated)
  ("s" "sync database" org-roam-db-sync)
  ("/" "search notes" consult-org-roam-search))

(my-define-menu my-notes-map
  ("*" "search notes for symbol" my-notes-search-symbol)
  ("a" "org agenda" org-agenda)
  ("c" "toggle last clock" my-org-toggle-last-clock)
  ("C" "cancel clock" org-clock-cancel)
  ("f" "find file in notes" my-notes-find-file)
  ("F" "browse notes" my-notes-browse)
  ("j" "journal entry" my-org-journal)
  ("l" "store link" org-store-link)
  ("m" "tags search" org-tags-view)
  ("n" "org capture" org-capture)
  ("N" "goto capture" org-capture-goto-target)
  ("o" "active clock" org-clock-goto)
  ("r" "roam" my-roam-map)
  ("s" "search notes" my-notes-search)
  ("S" "search agenda headlines" consult-org-agenda)
  ("t" "todo list" org-todo-list)
  ("v" "view search" org-search-view))

(my-define-menu my-open-map
  ("-" "dirvish" dirvish)
  ("b" "default browser" browse-url-of-file)
  ("f" "new frame" make-frame)
  ("F" "select frame" select-frame-by-name)
  ("m" "markdown preview" my-markdown-preview)
  ("p" "project sidebar" dirvish-side)
  ("t" "toggle terminal popup" my-terminal-toggle)
  ("T" "terminal here" my-terminal-here))

(my-define-menu my-project-map
  ("." "browse project" project-find-dir)
  ("!" "run command in root" project-shell-command)
  ("&" "async command in root" project-async-shell-command)
  ("b" "switch project buffer" consult-project-buffer)
  ("c" "compile project" project-compile)
  ("C" "recompile project" project-recompile)
  ("d" "forget project" project-forget-project)
  ("D" "discover projects" project-remember-projects-under)
  ("e" "edit .dir-locals" my-project-edit-dir-locals)
  ("f" "find file in project" project-find-file)
  ("F" "find file in other project" my-project-find-file-other)
  ("k" "kill project buffers" project-kill-buffers)
  ("n" "set up nix shell" my-project-environment-setup)
  ("o" "find sibling file" find-sibling-file)
  ("p" "switch project" project-switch-project)
  ("s" "save project buffers" my-project-save-buffers))

(my-define-menu my-quit-map
  ("d" "restart daemon" my-restart-daemon)
  ("f" "delete frame" delete-frame)
  ("K" "kill emacs" save-buffers-kill-emacs)
  ("l" "restore session" desktop-read)
  ("L" "restore session from" desktop-change-dir)
  ("q" "quit emacs" save-buffers-kill-terminal)
  ("Q" "quit without saving" my-quit-without-saving)
  ("r" "restart emacs" restart-emacs)
  ("s" "save session" desktop-save-in-desktop-dir)
  ("S" "save session to" desktop-save))

(my-define-menu my-search-map
  ("B" "search open buffers" consult-line-multi)
  ("d" "search directory" my-search-directory)
  ("D" "search other directory" my-search-other-directory)
  ("e" "search config" my-search-config)
  ("i" "jump to symbol" consult-imenu)
  ("I" "jump to symbol in buffers" consult-imenu-multi)
  ("j" "jump list" consult-global-mark)
  ("L" "jump to link" ffap-menu)
  ("m" "jump to bookmark" consult-bookmark)
  ("o" "look up online" eww-search-words)
  ("p" "search project" consult-ripgrep)
  ("P" "search other project" my-search-other-project)
  ("r" "jump to mark" consult-mark)
  ("s" "search buffer" consult-line)
  ("S" "search buffer for symbol" my-search-buffer-symbol)
  ("t" "dictionary" dictionary-lookup-definition))

(my-define-menu my-toggle-map
  ("b" "big text" global-text-scale-adjust)
  ("c" "fill column indicator" global-display-fill-column-indicator-mode)
  ("d" "git gutter" diff-hl-mode)
  ("f" "flymake" flymake-mode)
  ("F" "fullscreen" toggle-frame-fullscreen)
  ("g" "pulse on jumps" pulsar-global-mode)
  ("i" "indent guides" indent-bars-mode)
  ("I" "indent with tabs" indent-tabs-mode)
  ("l" "line numbers" display-line-numbers-mode)
  ("r" "read-only" read-only-mode)
  ("s" "spell checker" jinx-mode)
  ("v" "visible mode" visible-mode)
  ("w" "soft line wrapping" visual-line-mode)
  ("z" "zen mode" olivetti-mode))

(my-define-menu my-git-find-map
  ("c" "find commit" magit-show-commit)
  ("f" "find file" magit-find-file)
  ("g" "find gitconfig" magit-find-git-config-file))

(my-define-menu my-git-list-map
  ("r" "list repositories" magit-list-repositories)
  ("s" "list submodules" magit-list-submodules))

(my-define-menu my-git-create-map
  ("b" "branch" magit-branch-and-checkout)
  ("c" "commit" magit-commit-create)
  ("f" "fixup" magit-commit-fixup)
  ("r" "initialize repo" magit-init)
  ("R" "clone repo" magit-clone))

(my-define-menu my-git-map
  ("." "magit file dispatch" magit-file-dispatch)
  ("/" "magit dispatch" magit-dispatch)
  ("[" "previous hunk" diff-hl-previous-hunk)
  ("]" "next hunk" diff-hl-next-hunk)
  ("b" "switch branch" magit-branch-checkout)
  ("B" "blame" magit-blame-addition)
  ("c" "create" my-git-create-map)
  ("D" "delete file" magit-file-delete)
  ("f" "find" my-git-find-map)
  ("F" "fetch" magit-fetch)
  ("g" "status" magit-status)
  ("G" "status here" magit-status-here)
  ("l" "list" my-git-list-map)
  ("L" "file log" magit-log-buffer-file)
  ("r" "revert hunk" diff-hl-revert-hunk)
  ("R" "revert file" vc-revert)
  ("s" "stage hunk" diff-hl-stage-current-hunk)
  ("S" "stage file" magit-file-stage)
  ("U" "unstage file" magit-file-unstage))

(my-define-menu my-window-map
  ("+" "taller" enlarge-window)
  ("-" "shorter" shrink-window)
  ("<" "narrower" shrink-window-horizontally)
  (">" "wider" enlarge-window-horizontally)
  ("=" "balance" balance-windows)
  ("_" "full height" my-window-full-height)
  ("|" "full width" my-window-full-width)
  ("b" "bottom-right window" my-window-bottom-right)
  ("d" "close window" delete-window)
  ("f" "file at point in window" ffap-other-window)
  ("h" "window left" windmove-left)
  ("j" "window below" windmove-down)
  ("k" "window above" windmove-up)
  ("l" "window right" windmove-right)
  ("H" "move window left" windmove-swap-states-left)
  ("J" "move window down" windmove-swap-states-down)
  ("K" "move window up" windmove-swap-states-up)
  ("L" "move window right" windmove-swap-states-right)
  ("n" "new window" my-window-new)
  ("o" "maximize" maximize-window)
  ("p" "last window" my-window-last-used)
  ("q" "quit window" my-window-quit)
  ("r" "rotate" rotate-windows)
  ("R" "rotate back" rotate-windows-back)
  ("s" "split below" split-window-below)
  ("S" "split below and follow" my-window-split-below-follow)
  ("t" "top-left window" my-window-top-left)
  ("T" "tear off window" tear-off-window)
  ("u" "undo layout" winner-undo)
  ("U" "redo layout" winner-redo)
  ("v" "split right" split-window-right)
  ("V" "split right and follow" my-window-split-right-follow)
  ("w" "ace window" ace-window)
  ("W" "previous window" my-window-previous)
  ("x" "swap with next" my-window-exchange))

(my-define-menu my-fold-map
  ("z" "toggle fold" treesit-fold-toggle)
  ("o" "open all folds" treesit-fold-open-all)
  ("c" "close all folds" treesit-fold-close-all)
  ("+" "zoom in" text-scale-increase)
  ("-" "zoom out" text-scale-decrease))

(my-define-keys
 mode-specific-map
 '("SPC" "find file in project" project-find-file)
 '("/" "search project" consult-ripgrep)
 '("," "switch buffer" consult-buffer)
 '("." "find file" find-file)
 '("*" "search project for symbol" my-search-project-symbol)
 '("`" "last buffer" meow-last-buffer)
 '("'" "resume last search" vertico-repeat)
 '(";" "eval expression" pp-eval-expression)
 '(":" "M-x" execute-extended-command)
 '("~" "toggle side windows" window-toggle-side-windows)
 '("?" "meow cheatsheet" meow-cheatsheet)
 '("a" "code actions" my-code-actions)
 '("j" "jump to characters" avy-goto-char-timer)
 '("J" "jump to line" avy-goto-line)
 '("S" "correct spelling" jinx-correct)
 '("u" "undo tree" vundo))

(my-define-keys
 mode-specific-map
 '("b" "buffer" my-buffer-map)
 '("d" "docs" my-docs-map)
 '("e" "errors" my-errors-map)
 '("f" "file" my-file-map)
 '("i" "insert" my-insert-map)
 '("k" "macros" my-macro-map)
 '("l" "code" my-code-map)
 '("n" "notes" my-notes-map)
 '("o" "open" my-open-map)
 '("p" "project" my-project-map)
 '("q" "quit" my-quit-map)
 '("s" "search" my-search-map)
 '("t" "toggle" my-toggle-map)
 '("v" "git" my-git-map)
 '("w" "window" my-window-map)
 '("z" "folds and zoom" my-fold-map))

(keymap-global-set "C-." #'embark-act)
(keymap-global-set "<remap> <describe-function>" #'helpful-callable)
(keymap-global-set "<remap> <describe-variable>" #'helpful-variable)
(keymap-global-set "<remap> <describe-key>" #'helpful-key)
(keymap-global-set "<remap> <describe-command>" #'helpful-command)
(keymap-set meow-keymap "<remap> <describe-key>" #'helpful-key)

(setq windmove-allow-all-windows t)

(dolist (map (list global-map meow-normal-state-keymap meow-insert-state-keymap
                   meow-motion-state-keymap))
  (keymap-set map "M-h" #'windmove-left)
  (keymap-set map "M-j" #'windmove-down)
  (keymap-set map "M-k" #'windmove-up)
  (keymap-set map "M-l" #'windmove-right))

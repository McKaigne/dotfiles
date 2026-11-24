;;; keys.el -*- lexical-binding: t -*-

;; The Space menu, on Doom Emacs's SPC layout (without Evil; Meow still edits):
;;   SPC SPC  find in project   SPC .  find file     SPC ,  switch buffer
;;   SPC :    command           SPC ;  eval          SPC /  search project
;;   SPC x    scratch           SPC X  capture       SPC u  universal argument
;;   SPC TAB  workspaces        SPC RET bookmarks    SPC `  last buffer
;; with Doom's groups: b buffer, c code, f file, g git, h help, i insert,
;; n notes, o open, p project, q quit, s search, t toggle, w window.
;; Only Doom's own duplicate keys are kept (b d = b k, s s = s b, ...).
;; Doom leaves these letters free, so they carry the rest:
;;   SPC e  editing Meow has no answer for: rectangle, iedit, align, links
;;   SPC z  folds (kirigami, C-~)       SPC d  debugger (dape, M-F5)
;;   SPC l  LLM agents (C-c a)          SPC j / J  jump to char / line
;; Centaur's other menus sit in Doom's groups: words on SPC s w (C-c d; SPC s t
;; is Doom's look-up), TODOs on SPC s x (C-c t), URLs on SPC o u (C-c C-z), the
;; mode line on SPC t M (C-F6). Menus that stayed open as hydras stay open too
;; (funcs.el). Centaur's own global keys (C-c ..., M-..., F-keys) work as
;; well, in every Meow state. SPC m is the major mode's C-c keys (SPC m c =
;; C-c C-c), SPC \ is Meta (SPC \ x = M-x) and SPC 0-9 a numeric prefix;
;; meow's editing keys are unchanged.

(require 'windmove)
(defvar my-leader-map (make-sparse-keymap "Commands"))

;; Labels are written as shown: `capitalize' would turn LLM into Llm.
(dolist (group '(("TAB" . "Workspaces")
                 ("b" . "Buffer")
                 ("c" . "Code")
                 ("f" . "File")
                 ("g" . "Git")
                 ("g c" . "Create")
                 ("g o" . "Open on remote")
                 ("h" . "Help")
                 ("h b" . "Bindings")
                 ("h r" . "Reload")
                 ("i" . "Insert")
                 ("l" . "LLM")
                 ("n" . "Notes")
                 ("n r" . "Roam")
                 ("o" . "Open")
                 ("o a" . "Agenda")
                 ("o u" . "URL")
                 ("p" . "Project")
                 ("q" . "Quit")
                 ("s" . "Search")
                 ("s w" . "Words")
                 ("s x" . "TODOs")
                 ("e" . "Edit")))
  (define-key my-leader-map (kbd (car group))
              (cons (cdr group) (make-sparse-keymap (cdr group)))))

;; Doom's SPC commands that Emacs has no single command for.
(defun my-project-find-file-dwim ()
  "Find a file in this project, or anywhere when outside one."
  (interactive)
  (call-interactively (if (project-current) #'project-find-file #'find-file)))

(defun my-project-buffer-dwim ()
  "Switch among this project's buffers, or all of them when outside one."
  (interactive)
  (call-interactively
   (if (project-current) #'consult-project-buffer #'consult-buffer)))

(defun my-symbol-at-point-regexp ()
  "The symbol at point as a literal search pattern, or nil."
  (when-let* ((symbol (thing-at-point 'symbol t)))
    (regexp-quote symbol)))

(defun my-search-project-symbol ()
  "Search the project for the symbol at point."
  (interactive)
  (consult-ripgrep nil (my-symbol-at-point-regexp)))

(defun my-search-buffer-symbol ()
  "Search this buffer for the symbol at point."
  (interactive)
  (consult-line (my-symbol-at-point-regexp)))

(defun my-search-directory ()
  "Search the current directory."
  (interactive)
  (consult-ripgrep default-directory))

(defun my-search-notes ()
  "Search the text of the notes."
  (interactive)
  (consult-ripgrep my-org-directory))

(defun my-find-in-notes ()
  "Find a file by name in the notes."
  (interactive)
  (consult-fd my-org-directory))

(defun my-capture-goto-target ()
  "Pick a capture template and visit where it files entries."
  (interactive)
  (org-capture '(4)))

(defun my-find-in-config ()
  "Find a file in this Emacs configuration."
  (interactive)
  (let ((default-directory "/etc/nixos/modules/programs/emacs/"))
    (call-interactively #'find-file)))

(defun my-save-project-buffers ()
  "Save the changed buffers under the current project or directory."
  (interactive)
  (save-some-buffers nil #'save-some-buffers-root))

;; Doom closes a workspace's buffers; workspaces here are project tabs.
;; Only file and directory buffers count, so terminals, agent sessions and
;; Emacs's own buffers survive, as do other projects' files. Outside a
;; project there is no workspace, so nothing is closed.
(defun my-kill-project-buffers (&optional keep-current)
  "Close this project's file and directory buffers, asking first.
With KEEP-CURRENT, leave this buffer open."
  (unless (project-current)
    (user-error "Not in a project (SPC b k closes this buffer)"))
  (let* ((current (current-buffer))
         (files '(or buffer-file-name (derived-mode . dired-mode)))
         (project-kill-buffer-conditions
          (list (if keep-current
                    `(and (not ,(lambda (buffer) (eq buffer current))) ,files)
                  files))))
    (call-interactively #'project-kill-buffers)))

(defun my-kill-other-buffers ()
  "Close the other file buffers in this project, asking first."
  (interactive)
  (my-kill-project-buffers t))

(defun my-kill-all-buffers ()
  "Close this project's file buffers, asking first."
  (interactive)
  (my-kill-project-buffers))

(defun my-quit-without-saving ()
  "Stop Emacs, and every client, without saving. Asks first."
  (interactive)
  (when (yes-or-no-p "Stop Emacs now and lose unsaved changes? ")
    (kill-emacs)))

;; The daemon is a socket-activated systemd service (default.nix), and
;; `restart-emacs' would re-exec without systemd's socket, so systemd
;; restarts it instead.
(defun my-restart-emacs ()
  "Save, then restart the Emacs daemon (or this Emacs, outside one)."
  (interactive)
  (if (not (daemonp))
      (restart-emacs)
    (save-some-buffers)
    (when (yes-or-no-p "Restart the Emacs daemon? Every frame closes. ")
      (call-process "systemctl" nil 0 nil "--user" "restart" "emacs.service"))))

(defun my-yank-buffer ()
  "Copy the whole buffer."
  (interactive)
  (kill-new (buffer-substring-no-properties (point-min) (point-max)))
  (message "Copied buffer"))

(defun my-buffer-path (&optional relative)
  "This buffer's file or directory, RELATIVE to the project when non-nil."
  (let ((path (or buffer-file-name default-directory))
        (project (and relative (project-current))))
    (if project (file-relative-name path (project-root project)) path)))

(defun my-yank-file-path ()
  "Copy this file's path."
  (interactive)
  (let ((path (my-buffer-path)))
    (kill-new path)
    (message "Copied %s" path)))

(defun my-yank-relative-path ()
  "Copy this file's path relative to the project."
  (interactive)
  (let ((path (my-buffer-path t)))
    (kill-new path)
    (message "Copied %s" path)))

(defun my-insert-file-name ()
  "Insert this buffer's file name."
  (interactive)
  (unless buffer-file-name
    (user-error "This buffer isn't visiting a file"))
  (insert (file-name-nondirectory buffer-file-name)))

;; SPC ' resumes the last search.
(add-hook 'minibuffer-setup-hook #'vertico-repeat-save)

;; Magit doesn't autoload these two.
(autoload 'magit-file-stage "magit-files" nil t)
(autoload 'magit-file-unstage "magit-files" nil t)

;; Centaur's toggles hydra (F6) on Doom's SPC t letters, minus its theme and
;; package-archive columns (Noctalia sets the theme, Nix the packages), plus
;; this config's own toggles on the letters it leaves free.
(my-define-menu my-toggles-menu "Toggles"
  ("l" #'display-line-numbers-mode "line numbers")
  ("s" #'flyspell-mode "spell check")
  ("f" #'flymake-mode "flymake")
  ("F" #'toggle-frame-fullscreen "fullscreen")
  ("w" #'visual-line-mode "soft wrap")
  ("z" #'olivetti-mode "zen (centered)")
  ("r" #'read-only-mode "read-only")
  ("R" #'centaur-read-mode "reading mode")
  ("i" #'indent-bars-mode "indent guides")
  ("I" (lambda () (interactive)
         (setq indent-tabs-mode (not indent-tabs-mode))
         (message "Indent with %s" (if indent-tabs-mode "tabs" "spaces")))
   "indent style")
  ("c" #'display-fill-column-indicator-mode "fill column")
  ("v" #'visible-mode "visible mode")
  ("d" #'global-hungry-delete-mode "hungry delete *")
  ("e" #'electric-pair-mode "electric pair *")
  ("p" #'prettify-symbols-mode "pretty symbol")
  ("P" #'global-page-break-lines-mode "page break lines *")
  ("b" #'display-battery-mode "battery *")
  ("t" #'display-time-mode "time *")
  ("m" #'doom-modeline-mode "modern mode-line *")
  ("M" #'my-mode-line-menu "mode line…" :exit t)
  ("h l" #'global-hl-line-mode "highlight line *")
  ("h p" #'show-paren-mode "highlight parenthesis *")
  ("h s" #'symbol-overlay-mode "highlight symbol")
  ("h r" #'global-colorful-mode "highlight color *")
  ("h w" (lambda () (interactive)
           (setq-default show-trailing-whitespace (not show-trailing-whitespace)))
   "highlight whitespace")
  ("h d" #'rainbow-delimiters-mode "highlight delimiter")
  ("h t" #'global-hl-todo-mode "highlight todo *")
  ("O" #'hs-minor-mode "hideshow")
  ("u" #'subword-mode "subword")
  ("W" #'which-function-mode "current function *")
  ("E" #'toggle-debug-on-error "debug on error")
  ("Q" #'toggle-debug-on-quit "debug on quit")
  ("g g" #'global-diff-hl-mode "gutter *")
  ("g l" #'diff-hl-flydiff-mode "live gutter *")
  ("g m" #'diff-hl-margin-mode "margin gutter *")
  ("g d" #'diff-hl-dired-mode "dired gutter")
  ("B" #'blamer-mode "line blame")
  ("A" #'apheleia-mode "format on save"))

;; Centaur's mode-line hydra (C-F6).
(defmacro my-mode-line-toggle (variable)
  "A command that flips VARIABLE and redraws the mode line."
  `(lambda () (interactive)
     (setq ,variable (not ,variable))
     (force-mode-line-update t)
     (message "%s: %s" ',variable (if ,variable "on" "off"))))
(my-define-menu my-mode-line-menu "Mode Line"
  ("i e" (my-mode-line-toggle doom-modeline-icon) "enable icons")
  ("i u" (my-mode-line-toggle doom-modeline-unicode-fallback) "unicode fallback")
  ("i m" (my-mode-line-toggle doom-modeline-major-mode-icon) "major mode icon")
  ("i c" (my-mode-line-toggle doom-modeline-major-mode-color-icon) "colorful major mode")
  ("i o" (my-mode-line-toggle doom-modeline-buffer-modification-icon) "modification icon")
  ("i s" (my-mode-line-toggle doom-modeline-buffer-state-icon) "buffer state icon")
  ("i t" (my-mode-line-toggle doom-modeline-time-icon) "time icon")
  ("i v" (my-mode-line-toggle doom-modeline-modal-icon) "modal icon")
  ("g h" (my-mode-line-toggle doom-modeline-hud) "hud")
  ("g m" (my-mode-line-toggle doom-modeline-minor-modes) "minor modes")
  ("g c" (my-mode-line-toggle doom-modeline-enable-word-count) "word count")
  ("g e" (my-mode-line-toggle doom-modeline-buffer-encoding) "encoding")
  ("g i" (my-mode-line-toggle doom-modeline-indent-info) "indent")
  ("g x" (my-mode-line-toggle doom-modeline-display-misc-in-all-mode-lines) "misc info")
  ("g l" (my-mode-line-toggle doom-modeline-lsp) "lsp")
  ("g p" (my-mode-line-toggle doom-modeline-project-name) "project")
  ("g w" (my-mode-line-toggle doom-modeline-workspace-name) "workspace")
  ("g s" (my-mode-line-toggle doom-modeline-spell) "spell")
  ("g b" (my-mode-line-toggle doom-modeline-battery) "battery")
  ("g g" (my-mode-line-toggle doom-modeline-github) "github")
  ("g t" (my-mode-line-toggle doom-modeline-time) "time")
  ("g v" (my-mode-line-toggle doom-modeline-env-version) "version"))

(dolist (binding
         `(("SPC" my-project-find-file-dwim "find in project")
           ("." find-file "find file")
           ("," my-project-buffer-dwim "switch buffer")
           ("<" consult-buffer "switch buffer (all)")
           ("`" mode-line-other-buffer "last buffer")
           ("'" vertico-repeat "resume last search")
           (":" execute-extended-command "command")
           (";" pp-eval-expression "eval expression")
           ("/" consult-ripgrep "search project")
           ("*" my-search-project-symbol "search symbol in project")
           ("x" create-scratch-buffer "scratch")
           ("X" org-capture "capture")
           ("u" meow-universal-argument "universal argument")
           ("RET" bookmark-jump "jump to bookmark")
           ("~" popper-toggle "toggle popup")
           ("j" avy-goto-char-timer "jump")
           ("J" avy-goto-line "jump to line")
           ("a" embark-act "act on this")
           ;; Centaur's hydras
           ("t" my-toggles-menu "toggles…")
           ("w" my-window-menu "windows…")
           ("z" my-kirigami-menu "folds…")
           ("d" my-dape-menu "debugger…")
           ;; Workspaces (project-x's tabs)
           ("TAB TAB" tab-switch "switch")
           ("TAB n" tab-new "new")
           ("TAB d" tab-close "close")
           ("TAB r" tab-rename "rename")
           ("TAB ]" tab-next "next")
           ("TAB [" tab-previous "previous")
           ("TAB s" project-x-window-state-save "save session")
           ("TAB R" project-x-restore-last-project "restore last session")
           ;; Buffer
           ("b b" my-project-buffer-dwim "switch")
           ("b B" consult-buffer "switch (all)")
           ("b c" clone-indirect-buffer "clone")
           ("b d" kill-current-buffer "close")
           ("b k" kill-current-buffer "close")
           ("b i" ibuffer "buffer list")
           ("b K" my-kill-all-buffers "close all")
           ("b l" mode-line-other-buffer "last buffer")
           ("b m" bookmark-set "set bookmark")
           ("b M" bookmark-delete "delete bookmark")
           ("b n" next-buffer "next")
           ("b ]" next-buffer "next")
           ("b p" previous-buffer "previous")
           ("b [" previous-buffer "previous")
           ("b N" my-new-buffer "blank buffer")
           ("b O" my-kill-other-buffers "close others")
           ("b r" revert-buffer-quick "revert")
           ("b R" rename-buffer "rename")
           ("b s" save-buffer "save")
           ("b S" save-some-buffers "save all")
           ("b x" create-scratch-buffer "scratch")
           ("b y" my-yank-buffer "copy buffer")
           ("b z" bury-buffer "bury")
           ;; Code
           ("c a" eglot-code-actions "actions")
           ("c b" xref-go-back "back")
           ("c d" xref-find-definitions "definition")
           ("c D" xref-find-references "references")
           ("c e" quickrun "run this file")
           ("c f" apheleia-format-buffer "format")
           ("c i" eglot-find-implementation "implementation")
           ("c j" consult-eglot-symbols "workspace symbols")
           ("c k" eldoc-mouse-pop-doc-at-cursor "documentation")
           ("c l" eglot "connect LSP")
           ("c n" flymake-goto-next-error "next issue")
           ("c o" eglot-code-action-organize-imports "organize imports")
           ("c p" flymake-goto-prev-error "previous issue")
           ("c r" eglot-rename "rename")
           ("c t" eglot-find-typeDefinition "type definition")
           ("c w" delete-trailing-whitespace "delete trailing spaces")
           ("c x" flymake-show-buffer-diagnostics "list errors")
           ("c X" consult-flymake "search errors")
           ;; File
           ("f d" consult-dir "directory")
           ("f D" delete-this-file "delete this file")
           ("f f" find-file "find file")
           ("f i" file-info-show "file info")
           ("f n" my-new-file "new file")
           ("f p" my-find-in-config "find in config")
           ("f r" consult-recent-file "recent files")
           ("f R" rename-this-file "rename this file")
           ("f s" save-buffer "save")
           ("f S" write-file "save as")
           ("f u" sudo-edit-find-file "find as root")
           ("f U" sudo-edit "edit this as root")
           ("f y" my-yank-file-path "copy path")
           ("f Y" my-yank-relative-path "copy project path")
           ("f 8" save-buffer-as-utf8 "save as UTF-8")
           ;; Git
           ("g g" magit-status "status")
           ("g G" magit-status-here "status here")
           ("g /" magit-dispatch "actions")
           ("g ." magit-file-dispatch "file actions")
           ("g b" magit-branch-checkout "switch branch")
           ("g B" magit-blame-addition "blame")
           ("g C" magit-clone "clone")
           ("g c c" magit-commit-create "commit")
           ("g c f" magit-commit-instant-fixup "fixup")
           ("g c b" magit-branch-and-checkout "branch")
           ("g h" diff-hl-show-hunk "show change")
           ("g i" blamer-show-commit-info "line commit info")
           ("g L" magit-log-buffer-file "file log")
           ("g m" my-smerge-menu "merge conflicts…")
           ("g o o" browse-at-remote "this file")
           ("g p" git-messenger:popup-message "line commit message")
           ("g P" my-magit-repository "pick repository")
           ("g r" diff-hl-revert-hunk "revert change")
           ("g s" diff-hl-stage-current-hunk "stage change")
           ("g S" magit-file-stage "stage file")
           ("g t" git-timemachine "file history")
           ("g U" magit-file-unstage "unstage file")
           ("g y" browse-at-remote-kill "copy remote URL")
           ("g ]" diff-hl-next-hunk "next change")
           ("g [" diff-hl-previous-hunk "previous change")
           ;; Help
           ("h a" apropos "apropos")
           ("h b b" embark-bindings "all keys (search)")
           ("h b g" my-open-keybindings "key guide")
           ("h e" view-echo-area-messages "messages")
           ("h f" describe-function "function")
           ("h F" describe-face "face")
           ("h i" info "manuals")
           ("h I" consult-info "search manuals")
           ("h k" describe-key "key")
           ("h l" view-lossage "recent keys")
           ("h L" find-library "library")
           ("h m" describe-mode "mode")
           ("h o" helpful-at-point "thing at point")
           ("h r r" reload-init-file "reload config")
           ("h t" consult-theme "theme")
           ("h T" meow-tutor "Meow tutorial")
           ("h v" describe-variable "variable")
           ("h w" where-is "where is command")
           ("h x" consult-mode-command "mode commands")
           ("h ?" meow-cheatsheet "Meow cheatsheet")
           ;; Insert
           ("i c" consult-colors-emacs "color name")
           ("i C" consult-colors-web "web color")
           ("i e" emoji-search "emoji")
           ("i f" my-insert-file-name "file name")
           ("i s" yas-insert-snippet "snippet")
           ("i S" consult-yasnippet "snippet (search)")
           ("i t" hl-todo-insert "TODO")
           ("i u" insert-char "unicode")
           ("i y" consult-yank-pop "from kill ring")
           ;; LLM (C-c a)
           ("l c" agent-shell-anthropic-start-claude-code "Claude Code")
           ("l x" agent-shell-openai-start-codex "Codex")
           ("l a" agent-shell "agent shell")
           ("l A" agent-shell-new-shell "new agent shell")
           ("l g" gptel "chat (gptel)")
           ("l G" gptel-menu "gptel menu")
           ("l l" my-chatgpt-login "ChatGPT login")
           ;; Notes
           ("n a" org-agenda "agenda")
           ("n B" org-switchb "org buffers")
           ("n e" org-export-dispatch "export")
           ("n f" my-find-in-notes "find note file")
           ("n F" my-org-open "browse notes")
           ("n j" my-org-journal "journal")
           ("n l" org-store-link "store link")
           ("n m" org-tags-view "tags")
           ("n n" org-capture "capture")
           ("n N" my-capture-goto-target "go to capture target")
           ("n s" my-search-notes "search notes")
           ("n S" consult-org-agenda "search headlines")
           ("n t" org-todo-list "todo list")
           ("n r c" org-roam-capture "capture note")
           ("n r f" org-roam-node-find "find / create note")
           ("n r g" org-roam-graph "graph")
           ("n r i" org-roam-node-insert "insert link")
           ("n r r" org-roam-buffer-toggle "backlinks")
           ("n r u" org-roam-ui-mode "graph in browser")
           ;; Open
           ("o -" my-file-manager "file manager")
           ("o a a" org-agenda "agenda")
           ("o a m" org-tags-view "tags")
           ("o a t" org-todo-list "todo list")
           ("o b" browse-this-file "browser")
           ("o B" bookmark-bmenu-list "bookmarks")
           ("o c" pomidor "pomodoro")
           ("o d" dape "debugger")
           ("o D" docker "docker")
           ("o e" my-terminal "eshell")
           ("o f" make-frame "new frame")
           ("o F" select-frame-by-name "select frame")
           ("o h" open-dashboard "dashboard")
           ("o i" erc "IRC")
           ("o m" my-markdown-preview "Markdown preview")
           ("o N" newsticker-show-news "news")
           ("o o" reveal-in-folder "reveal in folder")
           ("o p" treemacs "file tree")
           ("o P" treemacs-find-file "find in file tree")
           ("o t" popterm-toggle "terminal")
           ("o T" ghostel "new terminal")
           ("o u ." browse-url-at-point "URL at point")
           ("o u u" browse-url "URL")
           ("o u b" browse-url-of-buffer "this buffer")
           ("o u r" browse-url-of-region "region")
           ("o u e" browse-url-emacs "URL in Emacs")
           ("o u f" browse-url-of-dired-file "file in dired")
           ("o x" proced "processes")
           ("o z" ztree-diff "compare directories")
           ("o =" elfeed "feeds (elfeed)")
           ;; Project
           ("p p" my-project-open "open project")
           ("p b" consult-project-buffer "project buffers")
           ("p c" project-compile "compile")
           ("p C" recompile "recompile")
           ("p d" project-forget-project "forget project")
           ("p e" my-project-environment-setup "set up Nix shell")
           ("p E" envrc-reload "reload environment")
           ("p f" project-find-file "find file")
           ("p k" project-kill-buffers "close its buffers")
           ("p o" ff-find-other-file "other file (header/source)")
           ("p s" my-save-project-buffers "save its buffers")
           ("p t" magit-todos-list "TODOs")
           ("p T" ghostel-project "terminal")
           ("p !" project-shell-command "run command")
           ("p &" project-async-shell-command "run command (async)")
           ;; Search
           ("s b" consult-line "buffer text")
           ("s B" consult-line-multi "all buffers' text")
           ("s c" goto-last-change "last change")
           ("s d" my-search-directory "this directory")
           ("s f" consult-fd "file names")
           ("s h" symbol-overlay-put "highlight symbol")
           ("s H" symbol-overlay-remove-all "clear highlights")
           ("s i" consult-imenu "symbols")
           ("s I" consult-imenu-multi "symbols, all buffers")
           ("s k" consult-keep-lines "keep lines")
           ("s m" consult-bookmark "bookmarks")
           ("s o" webjump "online")
           ("s p" consult-ripgrep "project text")
           ("s r" consult-mark "marks")
           ("s R" rg "rg")
           ("s s" consult-line "buffer text")
           ("s S" my-search-buffer-symbol "symbol at point")
           ("s u" vundo "undo history")
           ("s U" consult-focus-lines "focus lines")
           ;; Words: dictionary and translation (C-c d); s t is Doom's look-up
           ("s t" fanyi-dwim "dictionary")
           ("s w f" fanyi-dwim "look up")
           ("s w d" fanyi-dwim2 "look up at point")
           ("s w h" fanyi-from-history "history")
           ("s w g" gt-translate "translate")
           ("s w G" gt-translate-prompt "translate (prompt)")
           ("s w p" gt-speak "speak")
           ("s w s" gt-setup "set up translator")
           ("s w u" gt-use-text-utility "text utility")
           ;; TODOs (C-c t)
           ("s x o" hl-todo-occur "list in buffer")
           ("s x n" hl-todo-next "next")
           ("s x p" hl-todo-previous "previous")
           ("s x l" consult-todo "search buffer")
           ("s x a" consult-todo-all "search all buffers")
           ("s x r" hl-todo-rg-project "search project")
           ("s x R" hl-todo-rg "search directory")
           ;; Edit (Centaur's editing keys Meow has no answer for)
           ("e r" my-rectangle-menu "rectangle…")
           ("e i" iedit-mode "edit all occurrences")
           ("e a" ialign "align")
           ("e l" link-hint-open-link "open link")
           ("e L" link-hint-copy-link "copy link")
           ("e k" browse-kill-ring "kill ring")
           ("e m" consult-kmacro "keyboard macros")
           ("e s" consult-flyspell "spelling errors")
           ("e w" ispell-word "check word")
           ("e u" dos2unix "Unix line endings")
           ("e U" unix2dos "DOS line endings")
           ;; Quit
           ("q q" save-buffers-kill-terminal "close client")
           ("q f" delete-frame "close frame")
           ("q l" project-x-restore-last-project "restore last session")
           ("q r" my-restart-emacs "restart")
           ("q K" save-buffers-kill-emacs "stop the daemon")
           ("q Q" my-quit-without-saving "quit without saving")))
  (define-key my-leader-map (kbd (car binding))
              (cons (nth 2 binding) (nth 1 binding))))
(dotimes (digit 10)
  (define-key my-leader-map (number-to-string digit) #'meow-digit-argument))
;; SPC TAB 1-9 go straight to a workspace.
(dolist (tab (number-sequence 1 9))
  (define-key my-leader-map (kbd (format "TAB %d" tab))
              (cons (format "workspace %d" tab)
                    (lambda () (interactive) (tab-bar-select-tab tab)))))

;; Centaur's hydra keys outside the Space menu.
(bind-keys ("<f6>"   . my-toggles-menu)
           ("C-<f6>" . my-mode-line-menu))

;; Meow's Meta prefix is m by default, which would take SPC m from C-c.
(setq meow-keypad-leader-dispatch my-leader-map
      meow-keypad-start-keys '((?m . ?c))
      meow-keypad-meta-prefix ?\\
      meow-keypad-ctrl-meta-prefix ?G)

;; Meow's own popup shows the keys. It would call every labelled entry
;; "+prefix", so it gets the label, and it would list the <remap> row that
;; its display keymap carries.
(defun my-keypad-title (def)
  "The name Meow's popup shows for DEF: its label, if it has one."
  (pcase def
    (`(,(and (pred stringp) label) . ,target)
     (let ((title (make-symbol label)))
       ;; Meow shows a command as its name and anything else as +name.
       (unless (keymapp target) (fset title #'ignore))
       title))
    (_ (meow-keypad-get-title def))))

(defun my-keypad-popup (keymap)
  "Show KEYMAP in Meow's popup, without its <remap> row.
Meow leaves SPC, TAB, RET and m out of the top menu, so they go back in."
  (when keymap
    (setq keymap (assq-delete-all 'remap keymap))
    (unless meow--keypad-keys
      (dolist (key '(?\s ?\t ?\r))
        (define-key keymap (vector key)
                    (my-keypad-title (alist-get key my-leader-map))))
      (define-key keymap "m" (my-keypad-title '("mode keys (C-c)" . ignore)))))
  (meow-describe-keymap keymap))

(setq meow-keypad-get-title-function #'my-keypad-title
      meow-keypad-describe-keymap-function #'my-keypad-popup)

;; M-SPC opens the menu while typing, except in a completion popup, where it
;; stays corfu's separator for multi-word filtering.
(define-key meow-insert-state-keymap (kbd "M-SPC")
            '(menu-item "" meow-keypad
                        :filter (lambda (cmd) (unless completion-in-region-mode cmd))))

;; In Emacs's own maps where one fits.
(keymap-set project-prefix-map "C" #'recompile)
(keymap-set project-prefix-map "E" #'my-project-environment-setup)
(with-eval-after-load 'markdown-mode
  (keymap-set markdown-mode-map "C-c C-c v" #'my-markdown-preview)
  (keymap-set markdown-mode-map "C-c v" #'my-markdown-preview))
(with-eval-after-load 'markdown-ts-mode
  (keymap-set markdown-ts-mode-map "C-c v" #'my-markdown-preview))

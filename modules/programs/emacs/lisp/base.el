;;; base.el -*- lexical-binding: t -*-

;; Centaur Emacs's base settings (lisp/init-base.el). Left out: OS-specific
;; keys, exec-path-from-shell (the daemon's service starts from a login
;; shell), the server hook (systemd runs the daemon) and the frame-geometry
;; keys (Umbriel tiles frames). Backups stay in the state directory (core.el).

(setq ffap-machine-p-known 'reject)

;; Garbage Collector Magic Hack
(use-package gcmh
  :hook (emacs-startup . gcmh-mode)
  :init (setq gcmh-idle-delay 'auto
              gcmh-auto-idle-delay-factor 10
              gcmh-high-cons-threshold #x4000000)) ; 64MB

;; Set UTF-8 as the default coding system
(when (fboundp 'set-charset-priority)
  (set-charset-priority 'unicode))
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-next-selection-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(setq system-time-locale "C")

;; History
(use-package recentf
  :bind (("C-x C-r" . recentf-open-files))
  :init (setq recentf-max-saved-items 300
              recentf-exclude
              '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmarks"
                "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
                "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
                "^/tmp/" "^/var/folders/.+$" "^/ssh:" "/persp-confs/"
                "^/nix/store/"))
  :config
  (push (expand-file-name recentf-save-file) recentf-exclude)
  (add-to-list 'recentf-filename-handlers #'abbreviate-file-name))

(use-package savehist
  :init (setq enable-recursive-minibuffers t ; Allow commands in minibuffers
              history-length 1000
              savehist-additional-variables '(mark-ring
                                              global-mark-ring
                                              search-ring
                                              regexp-search-ring
                                              extended-command-history)
              savehist-autosave-interval 300))

;; Misc.
(use-package simple
  :ensure nil
  :hook ((after-init . size-indication-mode)
         (text-mode . visual-line-mode)
         ((prog-mode markdown-mode markdown-ts-mode conf-mode) . enable-trailing-whitespace))
  :init
  (setq column-number-mode t
        line-number-mode t
        kill-whole-line t               ; Kill line including '\n'
        line-move-visual nil
        track-eol t                     ; Keep cursor at end of lines.
        set-mark-command-repeat-pop t)  ; Repeating C-SPC after popping mark pops it again

  ;; Visualize TAB, (HARD) SPACE, NEWLINE
  (setq-default show-trailing-whitespace nil) ; Don't show trailing whitespace by default
  (defun enable-trailing-whitespace ()
    "Show trailing spaces and delete on saving."
    (setq show-trailing-whitespace t)
    (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

  ;; Prettify the process list
  (with-no-warnings
    (defun my/list-processes--prettify ()
      "Prettify process list."
      (when-let* ((entries tabulated-list-entries))
        (setq tabulated-list-entries nil)
        (dolist (p (process-list))
          (when-let* ((val (cadr (assoc p entries)))
                      (name (aref val 0))
                      (pid (aref val 1))
                      (status (aref val 2))
                      (status (list status
                                    'face
                                    (if (memq status '(stop exit closed failed))
                                        'error
                                      'success)))
                      (buf-label (aref val 3))
                      (tty (list (aref val 4) 'face 'font-lock-doc-face))
                      (thread (list (aref val 5) 'face 'font-lock-doc-face))
                      (cmd (list (aref val 6) 'face 'completions-annotations)))
            (push (list p (vector name pid status buf-label tty thread cmd))
                  tabulated-list-entries)))))
    (advice-add #'list-processes--refresh :after #'my/list-processes--prettify)))

(setq-default major-mode 'text-mode)
(setq inhibit-compacting-font-caches t  ; Don’t compact font caches during GC
      delete-by-moving-to-trash t       ; Deleting files go to OS's trash folder
      uniquify-buffer-name-style 'post-forward-angle-brackets ; Show path if names are same
      adaptive-fill-regexp "[ t]+|[ t]*([0-9]+.|*+)[ t]*"
      adaptive-fill-first-line-regexp "^* *$"
      sentence-end "\\([。！？]\\|……\\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*"
      sentence-end-double-space nil
      word-wrap-by-category t)

;; Frame transparency: C-M-9 / C-M-8 more / less, C-M-7 toggle. Only the
;; background, as the glass setting (ui.el) does.
(use-package transwin
  :bind (("C-M-9" . transwin-inc)
         ("C-M-8" . transwin-dec)
         ("C-M-7" . transwin-toggle))
  :init (setq transwin-parameter-alpha 'alpha-background))

;; Child frame
(use-package posframe
  :custom-face
  (child-frame-border ((t (:inherit posframe-border))))
  :hook (after-load-theme . posframe-delete-all)
  :init
  (defface posframe-border
    `((t (:inherit region)))
    "Face used by the `posframe' border."
    :group 'posframe)
  (defvar posframe-border-width 2
    "Default posframe border width.")
  :config
  (with-no-warnings
    ;; Popups are solid: through the frame's glass, the text under them
    ;; showed through and mixed with theirs.
    (defun my/posframe--prettify-frame (&rest _)
      (set-face-background 'fringe nil posframe--frame)
      (set-frame-parameter posframe--frame 'alpha-background 100))
    (advice-add #'posframe--create-posframe :after #'my/posframe--prettify-frame)

    (defun posframe-poshandler-frame-center-near-bottom (info)
      (cons (/ (- (plist-get info :parent-frame-width)
                  (plist-get info :posframe-width))
               2)
            (/ (+ (plist-get info :parent-frame-height)
                  (* 2 (plist-get info :font-height)))
               2)))))
(require 'posframe)

;; Global keybindings
(bind-keys ("s-r"     . revert-buffer-quick)
           ("C-x K"   . delete-this-file)
           ("C-c C-l" . reload-init-file))

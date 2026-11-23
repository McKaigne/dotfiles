;;; window.el -*- lexical-binding: t -*-

;; Centaur Emacs's window module (lisp/init-window.el). Its window hydra is
;; the SPC w menu (keys.el); C-c w opens it too, as in Centaur.

;; Directional window-selection routines
(use-package windmove
  :ensure nil
  :hook (window-setup . (lambda ()
                          (windmove-default-keybindings 'super))))
(windmove-default-keybindings 'super)

;; Restore old window configurations
(use-package winner
  :ensure nil
  :hook (window-setup . winner-mode)
  :init (setq winner-boring-buffers '("*Completions*"
                                      "*Compile-Log*"
                                      "*inferior-lisp*"
                                      "*Fuzzy Completions*"
                                      "*Apropos*"
                                      "*Help*"
                                      "*cvs*"
                                      "*Buffer List*"
                                      "*Ibuffer*"
                                      "*esh command on file*")))
(winner-mode 1)

;; Quickly switch windows
(use-package ace-window
  :custom-face
  (aw-leading-char-face ((t (:inherit font-lock-keyword-face :foreground unspecified :bold t :height 3.0))))
  (aw-minibuffer-leading-char-face ((t (:inherit font-lock-keyword-face :bold t :height 1.0))))
  (aw-mode-line-face ((t (:inherit mode-line-emphasis :bold t))))
  :bind (([remap other-window] . ace-window)
         ("C-c w" . my-window-menu)
         ("C-x |" . split-window-horizontally-instead)
         ("C-x _" . split-window-vertically-instead))
  :custom (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :config
  ;; Bind the menu to dispatch list
  (add-to-list 'aw-dispatch-alist '(?w my-window-menu) t))

(my-define-menu my-window-menu "Window Management"
  ("TAB" #'other-window "switch")
  ("x" #'ace-delete-window "delete")
  ("X" #'ace-delete-other-windows "delete other" :exit t)
  ("s" #'ace-swap-window "swap")
  ("a" #'ace-select-window "select" :exit t)
  ("m" #'toggle-frame-maximized "maximize" :exit t)
  ("u" #'toggle-frame-fullscreen "fullscreen" :exit t)
  ("h" #'shrink-window-horizontally "← narrower")
  ("j" #'enlarge-window "↓ taller")
  ("k" #'shrink-window "↑ shorter")
  ("l" #'enlarge-window-horizontally "→ wider")
  ("n" #'balance-windows "balance")
  ("r" #'split-window-right "split horizontally" :exit t)
  ("R" #'split-window-horizontally-instead "horizontally instead" :exit t)
  ("v" #'split-window-below "split vertically" :exit t)
  ("V" #'split-window-vertically-instead "vertically instead" :exit t)
  ("t" #'split-window-toggle "toggle split" :exit t)
  ("+" #'text-scale-increase "zoom in")
  ("=" #'text-scale-increase "zoom in")
  ("-" #'text-scale-decrease "zoom out")
  ("0" (lambda () (interactive) (text-scale-increase 0)) "zoom reset")
  ("o" #'set-frame-font "frame font")
  ("f" #'make-frame-command "new frame")
  ("d" #'delete-frame "delete frame")
  ("<left>" #'winner-undo "winner undo")
  ("<right>" #'winner-redo "winner redo"))

;; Enforce rules for popups
(use-package popper
  :custom
  (popper-group-function #'popper-group-by-project)
  (popper-echo-dispatch-actions t)
  :bind (:map popper-mode-map
         ("C-h z"     . popper-toggle)
         ("C-<tab>"   . popper-cycle)
         ("C-M-<tab>" . popper-toggle-type))
  :hook ((window-setup . popper-mode)
         (window-setup . popper-tab-line-mode))
  :init
  (setq popper-mode-line ""
        popper-reference-buffers
        '("\\*Messages\\*$"
          "Output\\*$" "\\*Pp Eval Output\\*$"
          "^\\*eldoc.*\\*$"
          "\\*Compile-Log\\*$"
          "\\*Completions\\*$"
          "\\*Warnings\\*$"
          "\\*Async Shell Command\\*$"
          "\\*Apropos\\*$"
          "\\*Backtrace\\*$"
          "\\*Calendar\\*$"
          "\\*Fd\\*$" "\\*Find\\*$" "\\*Finder\\*$"
          "\\*Kill Ring\\*$"
          "\\*Embark \\(Collect\\|Live\\):.*\\*$"

          bookmark-bmenu-mode
          comint-mode
          compilation-mode
          help-mode helpful-mode
          tabulated-list-mode
          Buffer-menu-mode

          flymake-diagnostics-buffer-mode

          gnus-article-mode devdocs-mode
          grep-mode occur-mode rg-mode
          osx-dictionary-mode fanyi-mode
          "^\\*gt-result\\*$" "^\\*gt-log\\*$"

          "^\\*Process List\\*$" process-menu-mode
          cargo-process-mode

          "^\\*.*eshell.*\\*.*$" eshell-mode
          "^\\*ghostel\\*$" ghostel-mode
          "^\\*.*shell.*\\*.*$" shell-mode
          "^\\*.*terminal.*\\*.*$" term-mode

          "\\*DAP Templates\\*$" dap-server-log-mode
          "\\*ELP Profiling Results\\*" profiler-report-mode
          "\\*package update results\\*$" "\\*Package-Lint\\*$"
          "\\*[Wo]*Man.*\\*$"
          "\\*ert\\*$"
          "\\*gud-debug\\*$"
          "\\*lsp-help\\*$" "\\*lsp session\\*$"
          "\\*quickrun\\*$"
          "\\*vc-.*\\**"
          "\\*diff-hl\\**"
          "^\\*macro expansion\\**"

          "\\*Agenda Commands\\*" "\\*Org Select\\*" "\\*Capture\\*" "^CAPTURE-.*\\.org*"
          "\\*Gofmt Errors\\*$" "\\*Go Test\\*$" godoc-mode
          "\\*docker-.+\\*" "\\*prolog\\*" "\\*rustfmt\\*$"
          inferior-python-mode inf-ruby-mode swift-repl-mode))
  :config
  (with-no-warnings
    (defun my/popper-fit-window-height (win)
      "Adjust the height of popup window WIN to fit the buffer's content."
      (let ((desired-height (floor (/ (frame-height) 3))))
        (fit-window-to-buffer win desired-height desired-height)))
    (setq popper-window-height #'my/popper-fit-window-height)

    (defun popper-close-window-hack (&rest _args)
      "Close popper window via `C-g'."
      (when (and (not (region-active-p))
                 popper-open-popup-alist)
        (let ((window (caar popper-open-popup-alist))
              (buffer (cdar popper-open-popup-alist)))
          (when (and (window-live-p window)
                     (buffer-live-p buffer)
                     (not (with-current-buffer buffer
                            (derived-mode-p 'eshell-mode
                                            'ghostel-mode
                                            'shell-mode
                                            'term-mode))))
            (delete-window window)))))
    (advice-add #'keyboard-quit :before #'popper-close-window-hack)))
(popper-mode 1)
(popper-tab-line-mode 1)

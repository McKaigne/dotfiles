;;; tools.el -*- lexical-binding: t -*-

;; Centaur Emacs's reader, dictionary, docker, utilities and AI modules
;; (lisp/init-reader.el, init-dict.el, init-docker.el, init-utils.el,
;; init-ai.el). Its elfeed and ztree hydras are menus (h or ? in elfeed,
;; C-<f5> in ztree). Left out: osx-dictionary (macOS) and elfeed-webkit /
;; xwidget (this Emacs has no WebKit). AI keys come from auth-source or the
;; environment, as in Centaur.

;; PDF reader
(progn
  (use-package pdf-view
    :ensure pdf-tools
    :defines pdf-annot-activate-created-annotations
    :functions pdf-tools-install
    :hook ((pdf-tools-enabled . pdf-view-auto-slice-minor-mode)
           (pdf-tools-enabled . pdf-isearch-minor-mode))
    :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
    :magic ("%PDF" . pdf-view-mode)
    :bind (:map pdf-view-mode-map
           ("C-s" . isearch-forward))
    :init (setq pdf-view-use-scaling t
                pdf-view-use-imagemagick nil
                pdf-annot-activate-created-annotations t)
    :config
    ;; Activate the package
    (pdf-tools-install t nil t nil)

    ;; Recover last viewed position
    (use-package saveplace-pdf-view
      :when (ignore-errors (pdf-info-check-epdfinfo) t)
      :autoload (saveplace-pdf-view-find-file-advice saveplace-pdf-view-to-alist-advice)
      :functions pdf-info-check-epdfinfo
      :init
      (advice-add 'save-place-find-file-hook :around #'saveplace-pdf-view-find-file-advice)
      (advice-add 'save-place-to-alist :around #'saveplace-pdf-view-to-alist-advice))))

;; Epub reader
(use-package nov
  :mode ("\\.epub\\'" . nov-mode)
  :hook (nov-mode . my/nov-setup)
  :bind ("M-<f7>" . centaur-read-mode)
  :preface
  (defun my/nov-setup ()
    "Setup `nov-mode' for better reading experience."
    (visual-line-mode 1)
    (centaur-read-mode)
    (face-remap-add-relative 'variable-pitch :family "Times New Roman" :height 1.5))
  :config
  (with-no-warnings
    ;; HACK: ignore invalid metadata which caused by Unicode characters
    ;; @see https://github.com/wasamasa/nov.el/issues/63
    (defun my/nov-content-metadata (fn &rest args)
      "Wrapper for `nov-content-metadata'."
      (ignore-errors (apply fn args)))
    (advice-add #'nov-content-metadata :around #'my/nov-content-metadata))

  ;; Fix encoding issue on Windows
  (when sys/win32p
    (add-to-list 'process-coding-system-alist
                 `(,nov-unzip-program . (gbk . gbk)))))

;; Atom/RSS reader
(use-package elfeed
  :bind (("C-x j" . elfeed)
         :map elfeed-search-mode-map
         ("h" . my-elfeed-menu)
         ("?" . my-elfeed-menu))
  :init (setq url-queue-timeout 30
              elfeed-db-directory (locate-user-emacs-file ".elfeed")
              elfeed-show-entry-switch #'pop-to-buffer
              elfeed-show-entry-delete #'delete-window
              elfeed-feeds '(("https://planet.emacslife.com/atom.xml" planet emacslife)
                             ("http://www.masteringemacs.org/feed/" mastering)
                             ("https://oremacs.com/atom.xml" oremacs)
                             ("https://pinecast.com/feed/emacscast" emacscast)
                             ("https://emacstil.com/feed.xml" Emacs TIL)
                             ;; ("https://www.reddit.com/r/emacs.rss" reddit)
                             ))
  :config
  ;; Ignore db directory in recentf
  (push elfeed-db-directory recentf-exclude)

  ;; Add icons via tags
  (when (icons-displayable-p)
    (defun nerd-icon-for-tags (tags)
      "Generate Nerd Font icon based on tags.
  Returns default if no match."
      (cond ((member "youtube" tags)  (nerd-icons-faicon "nf-fa-youtube_play" :face '(:foreground "#FF0200")))
            ((member "instagram" tags) (nerd-icons-faicon "nf-fa-instagram" :face '(:foreground "#FF00B9")))
            ((or (member "emacs" tags) (member "emacslife" tags) (member "mastering" tags))
             (nerd-icons-sucicon "nf-custom-emacs" :face '(:foreground "#9A5BBE")))
            ((member "github" tags) (nerd-icons-faicon "nf-fa-github"))
            (t (nerd-icons-faicon "nf-fae-feedly" :face '(:foreground "#2AB24C")))))

    (defun my/elfeed-search-print-entry (entry)
      "Print ENTRY to the buffer."
      (let* ((date (elfeed-search-format-date (elfeed-entry-date entry)))
             (date-width (car (cdr elfeed-search-date-format)))
             (title (concat (or (elfeed-meta entry :title)
                                (elfeed-entry-title entry) "")
                            ;; NOTE: insert " " for overlay to swallow
                            " "))
             (title-faces (elfeed-search--faces (elfeed-entry-tags entry)))
             (feed (elfeed-entry-feed entry))
             (feed-title (when feed (or (elfeed-meta feed :title) (elfeed-feed-title feed))))
             (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
             (tags-str (mapconcat (lambda (s) (propertize s 'face 'elfeed-search-tag-face)) tags ","))
             (title-width (- (frame-width)
                             ;; (window-width (get-buffer-window (elfeed-search-buffer) t))
                             date-width elfeed-search-trailing-width))
             (title-column (elfeed-format-column
                            title (elfeed-clamp
                                   elfeed-search-title-min-width
                                   title-width
                                   elfeed-search-title-max-width) :left))

             ;; Title/Feed ALIGNMENT
             (align-to-feed-pixel (+ date-width
                                     (max elfeed-search-title-min-width
                                          (min title-width elfeed-search-title-max-width)))))
        (insert (propertize date 'face 'elfeed-search-date-face) " ")
        (insert (propertize title-column 'face title-faces 'kbd-help title))
        (put-text-property (1- (point)) (point) 'display `(space :align-to ,align-to-feed-pixel))
        (when feed-title
          (insert " " (concat (nerd-icon-for-tags tags) " ")
                  (propertize feed-title 'face 'elfeed-search-feed-face) " "))
        (when tags (insert "(" tags-str ")"))))

    (setq  elfeed-search-print-entry-function #'my/elfeed-search-print-entry))

  ;; Use xwidget if possible
  (when (xwidget-workable-p)
    (use-package elfeed-webkit
      :bind (:map elfeed-show-mode-map
             ("%" . elfeed-webkit-toggle))
      :config
      ;; Fix incorrect keymap after disabling webkit
      (defun my/elfeed-webkit-reset-keymap ()
        "Reset local keymap."
        (use-local-map elfeed-show-mode-map))
      (advice-add #'elfeed-webkit--disable :after #'my/elfeed-webkit-reset-keymap))))

;; Another Atom/RSS reader
(use-package newsticker
  :ensure nil
  :bind ("C-x J" . newsticker-show-news)
  :init (setq newsticker-url-list
              '(("Planet Emacslife" "https://planet.emacslife.com/atom.xml")
                ("Mastering Emacs" "http://www.masteringemacs.org/feed/")
                ("Oremacs" "https://oremacs.com/atom.xml")
                ("EmacsCast" "https://pinecast.com/feed/emacscast")
                ("Emacs Redux" "https://emacsredux.com/atom.xml")
                ("Emacs TIL" "https://emacstil.com/feed.xml")
                ;; ("Emacs Reddit" "https://www.reddit.com/r/emacs.rss")
                )))

;; A multi dictionaries interface
(use-package fanyi
  :bind (("C-c d f" . fanyi-dwim)
         ("C-c d d" . fanyi-dwim2)
         ("C-c d h" . fanyi-from-history)))

(use-package gt
  :bind (("C-c g"   . gt-translate)
         ("C-c G"   . gt-translate-prompt)
         ("C-c u"   . gt-use-text-utility)
         ("C-c d g" . gt-translate)
         ("C-c d G" . gt-translate-prompt)
         ("C-c d p" . gt-speak)
         ("C-c d s" . gt-setup)
         ("C-c d u" . gt-use-text-utility))
  :hook (after-load-theme . gt-configure)
  :init
  (setq gt-langs '(en zh)
        gt-buffer-render-follow-p t
        gt-buffer-render-window-config
        '((display-buffer-reuse-window display-buffer-in-direction)
          (direction . bottom)
          (window-height . 0.4)))
  :config
  (with-no-warnings
    (defun gt-configure ()
      "Set appearance and presets of go-translate."
      (setq gt-pop-posframe-forecolor (face-foreground 'tooltip nil t)
            gt-pop-posframe-backcolor (face-background 'tooltip nil t)
            gt-pin-posframe-bdcolor (face-background 'posframe-border nil t)

            gt-preset-translators
            `((default . ,(gt-translator
                           :taker (list (gt-taker :pick nil :if 'selection)
                                        (gt-taker :text 'paragraph
                                                  :if '(Info-mode help-mode helpful-mode devdocs-mode))
                                        (gt-taker :text 'buffer :pick 'fresh-word
                                                  :if (lambda (translatror)
                                                        (and (not (derived-mode-p 'fanyi-mode))
                                                             buffer-read-only)))
                                        (gt-taker :text 'word))
                           :engines (if (childframe-workable-p)
                                        (list (gt-bing-engine :if 'not-word)
                                              (gt-youdao-dict-engine :if 'word))
                                      (list (gt-bing-engine :if 'not-word)
                                            (gt-youdao-dict-engine :if 'word)
                                            (gt-youdao-suggest-engine :if 'word)
                                            (gt-google-engine :if 'word)))
                           :render (list (gt-posframe-pop-render
                                          :if (lambda (translator)
                                                (and (childframe-workable-p)
                                                     (not (derived-mode-p
                                                           'Info-mode
                                                           'help-mode
                                                           'helpful-mode
                                                           'devdocs-mode))
                                                     (not (member (buffer-name) '("COMMIT_EDITMSG")))))
                                          :frame-params (list :accept-focus nil
                                                              :width 70
                                                              :height 15
                                                              :left-fringe 16
                                                              :right-fringe 16
                                                              :border-width 1
                                                              :border-color gt-pin-posframe-bdcolor))
                                         (gt-overlay-render :if 'read-only)
                                         (gt-insert-render
                                          :if (lambda (translator)
                                                (member (buffer-name) '("COMMIT_EDITMSG"))))
                                         (gt-buffer-render))))
              (multi-dict . ,(gt-translator
                              :taker (gt-taker :prompt t)
                              :engines (list (gt-bing-engine)
                                             (gt-youdao-dict-engine)
                                             (gt-youdao-suggest-engine :if 'word)
                                             (gt-google-engine))
                              :render (gt-buffer-render)))
              (Text-Utility . ,(gt-text-utility
                                :taker (gt-taker :pick nil)
                                :render (gt-buffer-render))))))

    (gt-configure)

    (defun gt--translate (dict)
      "Translate using DICT from the preset translators."
      (gt-start (alist-get dict gt-preset-translators)))

    (defun gt-translate-prompt ()
      "Translate with prompt using the multiple dictionaries."
      (interactive)
      (gt--translate 'multi-dict))

    (defun gt-use-text-utility ()
      "Handle the texts with the utilities."
      (interactive)
      (gt--translate 'Text-Utility))))

;; OSX dictionary
(when sys/macp
  (use-package osx-dictionary
    :bind (("C-c d i" . osx-dictionary-search-input)
           ("C-c d x" . osx-dictionary-search-pointer))))

;; Docker
(unless sys/win32p
  (use-package docker
    :custom (docker-container-shell-file-name "/bin/bash")
    :bind ("C-c D" . docker))

  ;;`tramp-container' is builtin since 29
  (unless emacs/>=29p
    (use-package docker-tramp)))

(unless (and (centaur-treesit-available-p)
             (fboundp 'dockerfile-ts-mode))
  (use-package dockerfile-mode
    :functions centaur-treesit-available-p))

;; Display available keybindings in popup
(use-package persistent-scratch
  :custom
  (persistent-scratch-backup-file-name-format "%Y-%m-%d")
  (persistent-scratch-backup-directory (locate-user-emacs-file "persistent-scratch"))
  :bind (:map persistent-scratch-mode-map
         ([remap kill-buffer] . (lambda (&rest _)
                                  (interactive)
                                  (user-error "Scratch buffer cannot be killed")))
         ([remap revert-buffer] . persistent-scratch-restore)
         ([remap revert-buffer-quick] . persistent-scratch-restore))
  :hook ((after-init . persistent-scratch-autosave-mode)
         (lisp-interaction-mode . persistent-scratch-mode)))

;; Search tools
(use-package grep
  :ensure nil
  :custom (grep-use-headings t))

;; Writable `grep' buffer
(use-package wgrep
  :custom
  (wgrep-auto-save-buffer t)
  (wgrep-change-readonly-file t))

;; Fast search tool `ripgrep'
(use-package rg
  :defines rg-custom-type-aliases
  :hook (after-init . rg-enable-default-bindings)
  :config (add-to-list 'rg-custom-type-aliases '("tmpl" . "*.tmpl")))

;; A Simple and cool pomodoro timer
(use-package pomidor
  :bind ("s-<f12>" . pomidor)
  :init
  (setq alert-default-style 'mode-line)

  (when sys/macp
    (setq pomidor-play-sound-file
          (lambda (file)
            (when (executable-find "afplay")
              (start-process "pomidor-play-sound" nil "afplay" file))))))

;; Nice writing
(use-package olivetti
  :bind ("<f7>" . olivetti-mode)
  :init (setq olivetti-body-width 0.62))

;; Edit text for browsers with GhostText or AtomicChrome extension
(use-package atomic-chrome
  :hook ((emacs-startup . atomic-chrome-start-server)
         (atomic-chrome-edit-mode . delete-other-windows))
  :init (setq atomic-chrome-buffer-frame-width 100
              atomic-chrome-buffer-frame-height 30
              atomic-chrome-buffer-open-style 'frame)
  :config
  (when (fboundp 'gfm-mode)
    (setq atomic-chrome-url-major-mode-alist
          '(("github\\.com" . gfm-mode)
            ("gitlab\\.*"   . gfm-mode)))))

;; Process
(use-package proced
  :ensure nil
  :init
  (setq-default proced-format 'verbose)
  (setq proced-auto-update-flag t
        proced-auto-update-interval 3
        proced-enable-color-flag t))

;; Search
(use-package webjump
  :ensure nil
  :bind ("C-c /" . webjump)
  :init (setq webjump-sites
              '(;; Emacs
                ("Emacs Home Page" .
                 "www.gnu.org/software/emacs/emacs.html")
                ("Xah Emacs Site" . "ergoemacs.org/index.html")
                ("(or emacs irrelevant)" . "oremacs.com")
                ("Mastering Emacs" .
                 "https://www.masteringemacs.org/")

                ;; Search engines.
                ("DuckDuckGo" .
                 [simple-query "duckduckgo.com"
                               "duckduckgo.com/?q=" ""])
                ("Google" .
                 [simple-query "www.google.com"
                               "www.google.com/search?q=" ""])
                ("Bing" .
                 [simple-query "www.bing.com"
                               "www.bing.com/search?q=" ""])

                ("Baidu" .
                 [simple-query "www.baidu.com"
                               "www.baidu.com/s?wd=" ""])
                ("Wikipedia" .
                 [simple-query "wikipedia.org" "wikipedia.org/wiki/" ""]))))

;; IRC
(use-package erc
  :ensure nil
  :defines erc-interpret-mirc-color erc-autojoin-channels-alist
  :init (setq erc-interpret-mirc-color t
              erc-lurker-hide-list '("JOIN" "PART" "QUIT")
              erc-autojoin-channels-alist '(("freenode.net" "#emacs"))))

;; text mode directory tree
(use-package ztree
  :custom-face
  (ztreep-header-face ((t (:inherit diff-header :foreground unspecified))))
  (ztreep-arrow-face ((t (:inherit font-lock-comment-face :foreground unspecified))))
  (ztreep-leaf-face ((t (:inherit diff-index :foreground unspecified))))
  (ztreep-node-face ((t (:inherit font-lock-variable-name-face :foreground unspecified))))
  (ztreep-expand-sign-face ((t (:inherit font-lock-function-name-face))))
  (ztreep-diff-header-face ((t (:inherit (diff-header bold :foreground unspecified)))))
  (ztreep-diff-header-small-face ((t (:inherit diff-file-header :foreground unspecified))))
  (ztreep-diff-model-normal-face ((t (:inherit font-lock-doc-face :foreground unspecified))))
  (ztreep-diff-model-ignored-face ((t (:inherit font-lock-doc-face :strike-through t :foreground unspecified))))
  (ztreep-diff-model-diff-face ((t (:inherit diff-removed :foreground unspecified))))
  (ztreep-diff-model-add-face ((t (:inherit diff-nonexistent :foreground unspecified))))
  :bind (:map ztreediff-mode-map
         ("C-<f5>" . my-ztree-menu))
  :init (setq ztree-draw-unicode-lines t
              ztree-show-number-of-children t))

;; Misc
(use-package file-info
  :bind ("C-c c i" . file-info-show)
  :config
  (with-no-warnings
    (defun my/file-info-show (fn &rest args)
      "Wrapper for `file-info-show'."
      ;; display on the center of the frame
      (let ((hydra-posframe-show-params
             (plist-put (copy-alist hydra-posframe-show-params)
                        :poshandler #'posframe-poshandler-frame-center)))
        (apply fn args)))
    (advice-add 'file-info-show :around #'my/file-info-show)))

(use-package reveal-in-folder
  :bind ("C-c C-r" . reveal-in-folder))

;; Chat with ChatGPT or Claude. ChatGPT signs in with your subscription
;; (SPC A l, once). Claude's API has no
;; account login in gptel, so it needs an API key in authinfo:
;;   machine api.anthropic.com login apikey password <key>
(use-package gptel
  :functions (gptel-make-anthropic gptel-make-openai-oauth)
  :bind (("C-<f12>"   . gptel)
         ("C-M-<f12>" . gptel-menu)
         ("C-c a g"   . gptel)
         ("C-c a G"   . gptel-menu))
  :hook (gptel-mode . gptel-highlight-mode)
  :init
  ;; Keep the login token with Emacs's other state, not in the config.
  (setq gptel--openai-oauth-token-file (my-state-file "gptel-openai-oauth-token"))
  :config
  (gptel-make-anthropic "Claude"
    :stream t
    :key 'gptel-api-key)
  (setq gptel-model 'gpt-5.5
        gptel-backend (gptel-make-openai-oauth "ChatGPT")))

(defun my-chatgpt-login ()
  "Sign gptel in to ChatGPT with your subscription."
  (interactive)
  (require 'gptel)
  (call-interactively #'gptel-openai-oauth-login))
(bind-key "C-c a l" #'my-chatgpt-login)

;; The login token (with its long-lived refresh token) is for your eyes only.
(defun my-gptel-private-token (fn file &rest args)
  "Write the gptel login token FILE readable only by you."
  (prog1 (with-file-modes #o600 (apply fn file args))
    (set-file-modes file #o600)))
(advice-add 'gptel-oauth--write-token :around #'my-gptel-private-token)

(when emacs/>=29p
  ;; Generate commit messages for magit
  (use-package gptel-magit
    :hook (magit-mode . gptel-magit-install)
    :config
    ;; Ask for SPC A l instead of starting a browser login mid-commit.
    (defun my-gptel-magit-signed-in (&rest _)
      "Stop gptel-magit when ChatGPT has not been signed in to yet."
      (let ((backend (or gptel-magit-backend gptel-backend)))
        (when (and (gptel-openai-oauth-p backend)
                   (not (gptel-openai-oauth-token backend))
                   (not (file-exists-p gptel--openai-oauth-token-file)))
          (user-error "Sign in to ChatGPT first: SPC A l"))))
    (advice-add 'gptel-magit--request :before #'my-gptel-magit-signed-in))

  ;; Claude Code and Codex in Emacs (agent-shell talks to them through
  ;; claude-agent-acp and codex-acp). Both use your account: sign in once
  ;; with `claude' and `codex login' in a terminal. Claude Code comes
  ;; preselected when it asks which one.
  (use-package agent-shell
    :custom
    (agent-shell-display-action '(display-buffer-reuse-window))
    (agent-shell-agent-configs
     (list #'agent-shell-anthropic-make-claude-code-config
           #'agent-shell-openai-make-codex-config))
    (agent-shell-preferred-agent-config '(preselect . claude-code))
    :bind (("<f12>"      . agent-shell)
           ("<f13>"      . agent-shell)
           ("C-c a a"    . agent-shell)
           ("C-c a A"    . agent-shell-new-shell)
           ("C-c a c"    . agent-shell-anthropic-start-claude-code)
           ("C-c a x"    . agent-shell-openai-start-codex)
           :map agent-shell-mode-map
           ("C-h ?"      . agent-shell-help-menu)
           ("C-<return>" . agent-shell-help-menu))
    :config
    (with-no-warnings
      ;; Integrate into magit
      (with-eval-after-load 'magit
        (defun centaur-generate-commit ()
          "Generate conventional commit message from staged changes."
          (interactive)
          (if (magit-staged-files)
              (agent-shell-insert
               :submit t
               :text "Commit changes with conventional message")
            (user-error "No staged changes")))

        (defun centaur-review-commit ()
          "Send the commit at point to agent-shell for review."
          (interactive)
          (if-let* ((commit (magit-commit-p (magit-thing-at-point 'git-revision t))))
              (agent-shell-insert
               :submit t
               :text (format "Review commit: %s" commit))
            (user-error "No magit commit at point")))

        (bind-keys :map magit-mode-map
          ("C-c C-g" . centaur-generate-commit)
          ("C-c C-r" . centaur-review-commit))))))

(my-define-menu my-elfeed-menu "Elfeed"
  :pre (require 'elfeed)
  ("c" #'elfeed-db-compact "compact db")
  ("g" #'elfeed-search-update--force "refresh")
  ("G" #'elfeed-search-fetch "update")
  ("y" #'elfeed-search-yank "copy URL")
  ("+" #'elfeed-search-tag-all "tag all")
  ("-" #'elfeed-search-untag-all "untag all")
  ("<" #'elfeed-search-first-entry "first entry")
  (">" #'elfeed-search-last-entry "last entry")
  ("l" #'elfeed-search-live-filter "live filter")
  ("s" #'elfeed-search-set-filter "set filter")
  ("*" (lambda () (interactive) (elfeed-search-set-filter "@6-months-ago +star")) "starred")
  ("a" (lambda () (interactive) (elfeed-search-set-filter "@6-months-ago")) "all")
  ("t" (lambda () (interactive) (elfeed-search-set-filter "@1-day-ago")) "today")
  ("b" #'elfeed-search-browse-url "browse")
  ("n" #'next-line "next")
  ("p" #'previous-line "previous")
  ("u" #'elfeed-search-tag-all-unread "mark unread")
  ("r" #'elfeed-search-untag-all-unread "mark read")
  ("RET" #'elfeed-search-show-entry "show"))

(my-define-menu my-ztree-menu "Ztree"
  ("C" #'ztree-diff-copy "copy" :exit t)
  ("h" #'ztree-diff-toggle-show-equal-files "show/hide equals" :exit t)
  ("H" #'ztree-diff-toggle-show-filtered-files "show/hide ignores" :exit t)
  ("D" #'ztree-diff-delete-file "delete" :exit t)
  ("v" #'ztree-diff-view-file "view" :exit t)
  ("d" #'ztree-diff-simple-diff-files "simple diff" :exit t)
  ("r" #'ztree-diff-partial-rescan "partial rescan" :exit t)
  ("R" #'ztree-diff-full-rescan "full rescan" :exit t)
  ("RET" #'ztree-perform-action "expand/collapse or view" :exit t)
  ("SPC" #'ztree-perform-soft-action "expand/collapse or view in other" :exit t)
  ("TAB" #'ztree-jump-side "jump side" :exit t)
  ("g" #'ztree-refresh-buffer "refresh" :exit t)
  ("x" #'ztree-toggle-expand-subtree "expand/collapse" :exit t)
  ("<backspace>" #'ztree-move-up-in-tree "go to parent" :exit t))

;; file-info shows its panel with hydra; in a floating box, as in Centaur.
(with-eval-after-load 'hydra
  (setq hydra-hint-display-type 'posframe
        hydra-posframe-show-params
        `(:left-fringe 8
          :right-fringe 8
          :internal-border-width ,posframe-border-width
          :internal-border-color ,(face-background 'posframe-border nil t)
          :background-color ,(face-background 'tooltip nil t)
          :foreground-color ,(face-foreground 'tooltip nil t)
          :lines-truncate t
          :poshandler posframe-poshandler-frame-center-near-bottom)))

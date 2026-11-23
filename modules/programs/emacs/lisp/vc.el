;;; vc.el -*- lexical-binding: t -*-

;; Centaur Emacs's version-control module (lisp/init-vc.el); its smerge and
;; git-messenger hydras are menus here. Plus inline blame on each line
;; (blamer), from this config.

(use-package magit
  :commands (magit-status magit-dispatch)
  :custom
  (magit-diff-refine-hunk t)
  (git-commit-major-mode 'git-commit-elisp-text-mode))

;; Show TODOs in magit
(use-package magit-todos
  :after magit-status
  :commands magit-todos-mode
  :init
  (setq magit-todos-nice (if (executable-find "nice") t nil))
  (with-eval-after-load 'magit (magit-todos-mode 1)))

;; Walk through git revisions of a file
(use-package git-timemachine
  :custom-face
  (git-timemachine-minibuffer-author-face ((t (:inherit success :foreground unspecified))))
  (git-timemachine-minibuffer-detail-face ((t (:inherit warning :foreground unspecified))))
  :bind (:map vc-prefix-map
         ("t" . git-timemachine))
  :hook ((git-timemachine-mode . (lambda ()
                                   "Improve `git-timemachine' buffers."
                                   ;; Display different colors in mode-line
                                   (when (derived-mode-p 'emacs-lisp-mode)
                                     (and (fboundp 'highlight-defined-mode)
                                          (highlight-defined-mode t)))
                                   ;; Display line numbers
                                   (when (derived-mode-p 'prog-mode 'yaml-mode 'yaml-ts-mode)
                                     (and (fboundp 'display-line-numbers-mode)
                                          (display-line-numbers-mode t)))))
         (before-revert . (lambda ()
                            (when (bound-and-true-p git-timemachine-mode)
                              (user-error "Cannot revert the timemachine buffer"))))))

;; Pop up last commit information of current line
(use-package git-messenger
  :bind (:map vc-prefix-map
         ("p" . git-messenger:popup-message)
         :map git-messenger-map
         ("m" . git-messenger:copy-message))
  :init (setq git-messenger:show-detail t
              git-messenger:use-magit-popup t)
  :config
  (with-no-warnings
    (my-define-menu my-git-messenger-menu "Git Messenger"
      ("s" #'git-messenger:popup-show "show" :exit t)
      ("c" #'git-messenger:copy-commit-id "copy hash" :exit t)
      ("m" #'git-messenger:copy-message "copy message" :exit t)
      ("," (lambda () (interactive)
             (catch 'git-messenger-loop (git-messenger:show-parent)))
       "go parent" :exit t))

    (defun my/git-messenger:format-detail (fn vcs commit-id author message)
      (if (eq vcs 'git)
          (let ((date (git-messenger:commit-date commit-id))
                (colon (propertize ":" 'face 'font-lock-comment-face)))
            (concat
             (format "%s%s %s \n%s%s %s\n%s  %s %s \n"
                     (propertize "Commit" 'face 'font-lock-keyword-face) colon
                     (propertize (substring commit-id 0 8) 'face 'font-lock-comment-face)
                     (propertize "Author" 'face 'font-lock-keyword-face) colon
                     (propertize author 'face 'font-lock-string-face)
                     (propertize "Date" 'face 'font-lock-keyword-face) colon
                     (propertize date 'face 'font-lock-string-face))
             (propertize (make-string 38 ?─) 'face 'font-lock-comment-face)
             message
             (propertize "\nPress q to quit" 'face '(:inherit (font-lock-comment-face italic)))))
        (funcall fn vcs commit-id author message)))
    (advice-add #'git-messenger:format-detail :around #'my/git-messenger:format-detail)

    (defun my/git-messenger:popup-message ()
      "Popup message with `posframe', and dispatch actions with a menu."
      (interactive)
      (let* ((vcs (git-messenger:find-vcs))
             (file (buffer-file-name (buffer-base-buffer)))
             (line (line-number-at-pos))
             (commit-info (git-messenger:commit-info-at-line vcs file line))
             (commit-id (car commit-info))
             (author (cdr commit-info))
             (msg (git-messenger:commit-message vcs commit-id))
             (popuped-message (if (git-messenger:show-detail-p commit-id)
                                  (git-messenger:format-detail vcs commit-id author msg)
                                (cl-case vcs
                                  (git msg)
                                  (svn (if (string= commit-id "-")
                                           msg
                                         (git-messenger:svn-message msg)))
                                  (hg msg)))))
        (setq git-messenger:vcs vcs
              git-messenger:last-message msg
              git-messenger:last-commit-id commit-id)
        (run-hook-with-args 'git-messenger:before-popup-hook popuped-message)
        (my-git-messenger-menu)
        (cond ((and (fboundp 'posframe-workable-p) (posframe-workable-p))
               (let ((buffer-name " *git-messenger*"))
                 (posframe-show buffer-name
                                :string popuped-message
                                :left-fringe 8
                                :right-fringe 8
                                :max-width (round (* (frame-width) 0.62))
                                :max-height (round (* (frame-height) 0.62))
                                :internal-border-width 1
                                :internal-border-color (face-background 'posframe-border nil t)
                                :foreground-color (face-foreground 'tooltip nil t)
                                :background-color (face-background 'tooltip nil t))
                 (unwind-protect
                     (push (read-event) unread-command-events)
                   (posframe-hide buffer-name))))
              (t (message "%s" popuped-message)))
        (run-hook-with-args 'git-messenger:after-popup-hook popuped-message)))
    (advice-add #'git-messenger:popup-close :override #'ignore)
    (advice-add #'git-messenger:popup-message :override #'my/git-messenger:popup-message)))

;; Resolve diff3 conflicts
(use-package smerge-mode
  :ensure nil
  :bind (:map smerge-mode-map
         ("C-c m" . my-smerge-menu))
  :hook ((find-file . (lambda ()
                        (save-excursion
                          (goto-char (point-min))
                          (when (re-search-forward "^<<<<<<< " nil t)
                            (smerge-mode 1)))))
         (magit-diff-visit-file . (lambda ()
                                    (when smerge-mode
                                      (my-smerge-menu))))))
(my-define-menu my-smerge-menu "Smerge"
  :pre (require 'smerge-mode)
  ("n" #'smerge-next "next")
  ("p" #'smerge-prev "previous")
  ("b" #'smerge-keep-base "keep base")
  ("u" #'smerge-keep-upper "keep upper")
  ("l" #'smerge-keep-lower "keep lower")
  ("a" #'smerge-keep-all "keep all")
  ("RET" #'smerge-keep-current "keep current")
  ("C-m" #'smerge-keep-current "keep current")
  ("<" #'smerge-diff-base-upper "diff upper/base")
  ("=" #'smerge-diff-upper-lower "diff upper/lower")
  (">" #'smerge-diff-base-lower "diff base/lower")
  ("R" #'smerge-refine "refine")
  ("E" #'smerge-ediff "ediff")
  ("C" #'smerge-combine-with-next "combine")
  ("r" #'smerge-resolve "resolve")
  ("k" #'smerge-kill-current "kill")
  ("ZZ" (lambda () (interactive) (save-buffer) (bury-buffer))
   "save and bury buffer" :exit t))

;; Open github/gitlab/bitbucket page
(use-package browse-at-remote
  :bind (:map vc-prefix-map
         ("B" . browse-at-remote)))

;; Git configuration modes
(use-package git-modes)

;; The last commit for each line, quietly at its end.
(defun my-enable-line-blame ()
  "Initialize inline Git history in local, tracked text files."
  (when (and (not (local-variable-p 'blamer-mode))
             buffer-file-name
             (not (file-remote-p buffer-file-name))
             (derived-mode-p 'prog-mode 'text-mode)
             (eq (vc-backend buffer-file-name) 'Git))
    (blamer-mode 1)))

(defun my-dirvish-enable-line-blame (_find-fn file)
  "Initialize annotations when Dirvish opens FILE from a preview buffer."
  (when-let* ((buffer (and (not (file-remote-p file)) (get-file-buffer file))))
    (with-current-buffer buffer (my-enable-line-blame))))

(use-package blamer
  :commands (blamer-mode blamer-show-commit-info)
  :hook (find-file . my-enable-line-blame)
  :init
  (advice-add 'dirvish--find-entry :after #'my-dirvish-enable-line-blame)
  :custom
  (blamer-idle-time 0.6)
  (blamer-type 'visual)
  (blamer-min-offset 0)
  (blamer-self-author-name nil)
  (blamer-author-formatter "%s · ")
  (blamer-datetime-formatter "%s · ")
  (blamer-commit-formatter "%s")
  (blamer-entire-formatter "  %s")
  (blamer-show-avatar-p nil)
  :config
  (set-face-attribute 'blamer-face nil
                      :inherit 'mode-line-inactive
                      :foreground 'unspecified :background 'unspecified
                      :slant 'italic :height 1.0))



;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; Identity
(setq user-full-name "Pollux"
      user-mail-address "pollux@castor.local")

;;; UI: theme, fonts, dashboard
(setq doom-theme 'doom-nano-light)
(setq doom-font (font-spec :family "Maple Mono NF" :size 14))
(setq display-line-numbers-type 'relative)

;; Cursor Shapes
(setq evil-normal-state-cursor '(box "white")
      evil-insert-state-cursor '((bar . 3) "white")
      evil-visual-state-cursor '(hollow "white")
      evil-replace-state-cursor '((hbar . 3) "white"))
(setq-default cursor-type 'box)

;; Dashboard banner
(when (file-exists-p (concat doom-user-dir "carabao.svg"))
  (setq fancy-splash-image (concat doom-user-dir "carabao.svg")))

;; Modeline
(use-package! doom-nano-modeline
  :config
  (doom-nano-modeline-mode 1)
  (global-hide-mode-line-mode 1))

;; Org
(setq org-directory "~/org/")

;; Shells
(setq shell-file-name (executable-find "bash"))
(setq explicit-shell-file-name "/run/current-system/sw/bin/nu")
(setq-default explicit-shell-file-name "/run/current-system/sw/bin/nu")
(setq-default vterm-shell "/run/current-system/sw/bin/nu")

;; =================================================================
;; Native Ghostel Terminal & Smart Code Runner
;; =================================================================
(defun +my/run-code ()
  "Save buffer and run in an interactive Ghostel terminal popup."
  (interactive)
  (save-buffer)
  (let* ((file (buffer-file-name))
         (ext (when file (file-name-extension file)))
         (proj-root (and (fboundp 'projectile-project-root) (projectile-project-root)))
         (has-cmake (and proj-root (file-exists-p (expand-file-name "CMakeLists.txt" proj-root))))
         (cmd (cond
               ;; 1. CMake Projects
               (has-cmake
                (format "cd %s && cmake --build build && ./build/app" (shell-quote-argument proj-root)))
               ;; 2. Single C++ Files
               ((member ext '("cpp" "cc" "cxx"))
                (format "clang++ -std=c++20 -Wall %s -o /tmp/a.out && /tmp/a.out" (shell-quote-argument file)))
               ;; 3. Single C Files
               ((string-equal ext "c")
                (format "clang -Wall %s -o /tmp/a.out && /tmp/a.out" (shell-quote-argument file)))
               ;; 4. Python
               ((string-equal ext "py")
                (format "python3 %s" (shell-quote-argument file)))
               ;; 5. Nushell / Bash scripts
               ((string-equal ext "nu")
                (format "nu %s" (shell-quote-argument file)))
               ((string-equal ext "sh")
                (format "bash %s" (shell-quote-argument file)))
               ;; Fallback
               (t (format "echo 'No runner configured for %s'" ext)))))
    (if (fboundp '+ghostel/toggle)
        (progn
          (+ghostel/toggle)
          (ghostel-send-string (concat cmd "\n")))
      (compile cmd))))

(after! ghostel
  (setq ghostel-default-shell "/run/current-system/sw/bin/nu")
  (map! :leader
        (:prefix ("o" . "open")
         :desc "Ghostel popup" "t" #'+ghostel/toggle
         :desc "Ghostel full"  "T" #'+ghostel/open)))

;; Bind SPC r r to the Ghostel Runner
(map! :leader
      (:prefix ("r" . "Run")
       :desc "Run code in terminal" "r" #'+my/run-code
       :desc "Compile project"      "c" #'compile))

;; Projectile
(after! projectile
  (setq projectile-enable-caching t
        projectile-indexing-method 'hybrid)
  (dolist (marker '("Cargo.toml" "pyproject.toml" "CMakeLists.txt" "compile_commands.json" "build.zig" "flake.nix"))
    (add-to-list 'projectile-project-root-files marker)))

;; Navigation
(setq scroll-margin 99999
      scroll-conservatively 0
      maximum-scroll-margin 0.5)

(map! :leader
      (:prefix ("j" . "jump")
       :desc "Jump to char" "j" #'avy-goto-char
       :desc "Jump to word" "w" #'avy-goto-word-1
       :desc "Jump to line" "l" #'avy-goto-line))

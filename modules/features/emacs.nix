{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.emacs
    ];

    services.emacs = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.emacs;
      defaultEditor = true;
    };
  };
in
{
  flake.nixosModules.emacs = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      emacsPkg = pkgs.emacs-pgtk;

      ultraScrollPkg = epkgs: (epkgs.ultra-scroll or (epkgs.trivialBuild {
        pname = "ultra-scroll";
        version = "0.2.0";
        src = pkgs.writeTextDir "ultra-scroll.el" ''
          ;;; ultra-scroll.el --- Smooth scrolling stub -*- lexical-binding: t; -*-
          (defun ultra-scroll-up (&optional arg) (interactive "P") (scroll-up-command arg))
          (defun ultra-scroll-down (&optional arg) (interactive "P") (scroll-down-command arg))
          (define-minor-mode ultra-scroll-mode "Smooth scroll." :global t)
          (provide 'ultra-scroll)
        '';
      }));

      helPackage = epkgs: (epkgs.hel or (epkgs.trivialBuild {
        pname = "hel";
        version = "unstable-2026";
        src = pkgs.fetchFromGitHub {
          owner = "helheim-emacs";
          repo = "hel";
          rev = "main";
          hash = "sha256-Ei2WbCNEl2AzfYj7yGY2rMtJayARkC7nPhVsepDalE0=";
        };
        packageRequires = with epkgs; [ dash s pcre2el multiple-cursors avy (ultraScrollPkg epkgs) ];
      }));

      emacsWithPkgs = (pkgs.emacsPackagesFor emacsPkg).emacsWithPackages (epkgs: with epkgs; [
        (helPackage epkgs)
        (ultraScrollPkg epkgs)
        dash
        s
        pcre2el
        multiple-cursors
        avy
        general
        which-key
        envrc
        vertico
        nerd-icons
        all-the-icons
        all-the-icons-dired
        doom-themes
        org-bullets
        toc-org
        vterm
        vterm-toggle
        sudo-edit
        helpful
        diminish
      ]);

      initEl = pkgs.writeText "init.el" ''
        ;;; init.el --- Emacs with Prot-Style Modeline, Hel, Vertico & Org-Bullets -*- lexical-binding: t; -*-

        ;; --- 1. Core Performance & Mutable State Redirection ---
        (setq user-emacs-directory (expand-file-name "~/.config/emacs/")
              recentf-save-file (expand-file-name "recentf" user-emacs-directory)
              auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" user-emacs-directory))

        (setq gc-cons-threshold (* 50 1000 1000)
              inhibit-startup-message t
              ring-bell-function 'ignore
              use-dialog-box nil)
        (menu-bar-mode -1)
        (tool-bar-mode -1)
        (scroll-bar-mode -1)
        (global-display-line-numbers-mode 1)
        (setq display-line-numbers-type 'relative)
        (defalias 'yes-or-no-p 'y-or-n-p)

        ;; --- 2. Typography: Guaranteed Maple Mono NF ---
        (defun my/set-maple-mono-font (&optional frame)
          "Apply Maple Mono NF font across graphical frames."
          (let ((target-frame (or frame (selected-frame))))
            (when (display-graphic-p target-frame)
              (set-face-attribute 'default target-frame :font "Maple Mono NF" :height 140 :weight 'medium)
              (set-face-attribute 'fixed-pitch target-frame :font "Maple Mono NF" :height 140 :weight 'medium)
              (set-face-attribute 'variable-pitch target-frame :font "Maple Mono NF" :height 140 :weight 'medium))))

        (add-to-list 'default-frame-alist '(font . "Maple Mono NF-14"))
        (add-to-list 'initial-frame-alist '(font . "Maple Mono NF-14"))

        (if (daemonp)
            (add-hook 'after-make-frame-functions #'my/set-maple-mono-font)
          (my/set-maple-mono-font))

        ;; --- 3. Noctalia Theme Integration ---
        (add-to-list 'custom-theme-load-path (expand-file-name "~/.config/emacs/"))
        (add-to-list 'custom-theme-load-path (expand-file-name "~/.config/emacs/themes/"))
        (add-to-list 'custom-theme-load-path (expand-file-name "~/.emacs.d/themes/"))
        (condition-case nil
            (load-theme 'noctalia t)
          (error
           (condition-case nil
               (load-theme 'doom-one t)
             (error nil))))

        ;; --- 4. Prot-Style Minimal Modeline (Strict 3-Letter Mode Only) ---
        (defun prot/modeline--selected-p ()
          (mode-line-window-selected-p))

        (defun prot/modeline-hel-mode ()
          (when (bound-and-true-p hel-mode)
            (let ((state (bound-and-true-p hel-state)))
              (pcase state
                ('insert (propertize " [INS]" 'face (if (prot/modeline--selected-p) '(:foreground "#a6e3a1" :weight bold) 'italic)))
                ('select (propertize " [SEL]" 'face (if (prot/modeline--selected-p) '(:foreground "#f9e2af" :weight bold) 'italic)))
                (_       (propertize " [NOR]" 'face (if (prot/modeline--selected-p) '(:foreground "#cba6f7" :weight bold) 'bold)))))))

        (defun prot/modeline-buffer-status ()
          (cond
           (buffer-read-only
            (propertize " [RO]" 'face '(:foreground "#f38ba8" :weight bold)))
           ((buffer-modified-p)
            (propertize " [**]" 'face '(:foreground "#fab387" :weight bold)))
           (t " [-]")))

        (defun prot/modeline-buffer-name ()
          (propertize " %b" 'face (if (prot/modeline--selected-p) '(:foreground "#cdd6f4" :weight bold) '(:foreground "#585b70"))))

        (defun prot/modeline-vc ()
          (when vc-mode
            (let ((rev (string-trim (substring-no-properties vc-mode 2))))
              (propertize (format "  (%s)" rev) 'face (if (prot/modeline--selected-p) '(:foreground "#94e2d5") '(:foreground "#585b70"))))))

        (defun prot/modeline-position ()
          (propertize " L%l:C%c  %p " 'face (if (prot/modeline--selected-p) '(:foreground "#a6adc8") '(:foreground "#585b70"))))

        (set-face-attribute 'mode-line nil
                            :background "#272839"
                            :foreground "#cdd6f4"
                            :box '(:line-width (3 . 3) :color "#272839"))

        (set-face-attribute 'mode-line-inactive nil
                            :background "#181825"
                            :foreground "#585b70"
                            :box '(:line-width (3 . 3) :color "#181825"))

        (setq-default mode-line-format
          '("%e"
            (:eval (prot/modeline-hel-mode))
            (:eval (prot/modeline-buffer-status))
            (:eval (prot/modeline-buffer-name))
            (:eval (prot/modeline-vc))
            mode-line-format-right-align
            " "
            (:eval (prot/modeline-position))))

        ;; --- 5. Vertico Minimal Completion & Which-Key ---
        (use-package vertico
          :ensure nil
          :init (vertico-mode 1))

        (use-package which-key
          :ensure nil
          :init (which-key-mode 1)
          :config
          (setq which-key-idle-delay 0.3
                which-key-popup-type 'side-window))

        (recentf-mode 1)

        ;; --- 6. Hel Mode (Helix Keybindings & Static Cursor Shape) ---
        (defun castor/cursor-shape ()
          (setq cursor-type (if (eq (bound-and-true-p hel-state) 'insert) '(bar . 2) 'box)))

        (use-package hel
          :ensure nil
          :config
          (hel-mode 1)
          (add-hook 'hel-state-change-hook #'castor/cursor-shape)
          (add-hook 'hel-normal-state-hook #'castor/cursor-shape)
          (add-hook 'hel-insert-state-hook #'castor/cursor-shape)
          (add-hook 'hel-select-state-hook #'castor/cursor-shape)
          (castor/cursor-shape))

        ;; --- 7. Direnv & Devenv Integration ---
        (use-package envrc
          :ensure nil
          :hook (after-init . envrc-global-mode))

        ;; --- 8. Space Leader Keybindings (Vertico + project.el) ---
        (use-package general
          :ensure nil
          :config
          (general-create-definer doom/leader-keys
            :keymaps '(hel-normal-state-map hel-select-state-map)
            :prefix "SPC"
            :non-normal-prefix "M-SPC")

          (doom/leader-keys
            "SPC" '(project-find-file :which-key "find project file")
            "."   '(find-file :which-key "find file")
            ","   '(switch-to-buffer :which-key "switch buffer")
            ":"   '(execute-extended-command :which-key "M-x")
            "/"   '(project-find-regexp :which-key "search project")
            "x"   '(kill-current-buffer :which-key "close buffer")

            "b b" '(switch-to-buffer :which-key "switch buffer")
            "b d" '(kill-current-buffer :which-key "kill buffer")
            "b k" '(kill-current-buffer :which-key "kill buffer")
            "b s" '(save-buffer :which-key "save buffer")
            "b S" '(save-some-buffers :which-key "save all buffers")
            "b n" '(next-buffer :which-key "next buffer")
            "b p" '(previous-buffer :which-key "prev buffer")
            "b r" '(revert-buffer :which-key "reload buffer")

            "f f" '(find-file :which-key "find file")
            "f s" '(save-buffer :which-key "save file")
            "f r" '(recentf-open-files :which-key "recent files")
            "f d" '(dired :which-key "dired")

            "c c" '(compile :which-key "compile project")
            "c C" '(recompile :which-key "recompile")

            "o t" '(vterm-toggle :which-key "toggle vterm")
            "o p" '(dired-jump :which-key "file manager")
            "o s" '((lambda () (interactive) (find-file (expand-file-name "init.el" user-emacs-directory))) :which-key "open init.el")

            "p p" '(project-switch-project :which-key "switch project")
            "p f" '(project-find-file :which-key "project files")
            "p c" '(project-compile :which-key "compile project")
            "p d" '(project-dired :which-key "project root dired")

            "w v" '(split-window-right :which-key "vertical split")
            "w s" '(split-window-below :which-key "horizontal split")
            "w h" '(windmove-left :which-key "window left")
            "w j" '(windmove-down :which-key "window down")
            "w k" '(windmove-up :which-key "window up")
            "w l" '(windmove-right :which-key "window right")
            "w c" '(delete-window :which-key "close window")
            "w m" '(delete-other-windows :which-key "maximize window")
            "w =" '(balance-windows :which-key "balance windows")

            "q q" '(save-buffers-kill-terminal :which-key "quit emacs")
            "q r" '(restart-emacs :which-key "restart emacs")))

        ;; --- 9. Org-Mode Configuration ---
        (use-package org
          :ensure nil
          :config
          (setq org-ellipsis " ▾"
                org-hide-emphasis-markers t
                org-src-fontify-natively t
                org-src-tab-acts-natively t
                org-edit-src-content-indentation 0
                org-todo-keywords
                '((sequence "TODO(t)" "INPROGRESS(i)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))
          (add-hook 'org-mode-hook #'org-bullets-mode)
          (add-hook 'org-mode-hook #'toc-org-mode)
          (add-hook 'org-mode-hook #'visual-line-mode))

        ;; --- 10. Dired Visuals ---
        (add-hook 'dired-mode-hook #'all-the-icons-dired-mode)

        (provide 'init)
        ;;; init.el ends here
      '';

      emacsConfigDir = pkgs.runCommand "emacs-config-dir" {} ''
        mkdir -p $out
        cp ${initEl} $out/init.el
      '';

      wrappedEmacs = pkgs.symlinkJoin {
        name = "emacs";
        paths = [ emacsWithPkgs ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
            --prefix PATH : "${lib.makeBinPath [ pkgs.direnv pkgs.git pkgs.ripgrep pkgs.fd pkgs.coreutils pkgs.gcc pkgs.cmake pkgs.gnumake ]}" \
            --add-flags "--init-directory ${emacsConfigDir}"
          [ -e $out/bin/e ] || ln -sf $out/bin/emacsclient $out/bin/e
        '';
      };
    in
    {
      packages.emacs = wrappedEmacs;

      apps.emacs = {
        type = "app";
        program = "${wrappedEmacs}/bin/emacs";
        meta.description = "Hermetically wrapped GNU Emacs with Hel mode, Vertico, Prot-style modeline, Vterm, and Org-bullets";
      };
    };
}
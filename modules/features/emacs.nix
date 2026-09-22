{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.emacs
    ];

    services.emacs = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.emacs;
      defaultEditor = false;
    };
  };
in
{
  flake.nixosModules.emacs = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      emacsPkg = pkgs.emacs-pgtk;

      emacsWithPkgs = (pkgs.emacsPackagesFor emacsPkg).emacsWithPackages (epkgs: with epkgs; [
        # Modal Editing & Doom Leader
        evil
        evil-collection
        general
        which-key

        # Project & Environment Tooling (Buffer-Local Direnv/Devenv)
        envrc

        # Completion & Selection (Ivy/Counsel stack)
        ivy
        counsel
        swiper
        ivy-rich

        # Aesthetics & Icons
        doom-modeline
        nerd-icons
        all-the-icons
        all-the-icons-dired
        doom-themes

        # Org Mode & Documentation
        org-bullets
        toc-org

        # Workspace & Terminals
        projectile
        counsel-projectile
        dashboard
        vterm
        sudo-edit
        helpful
        diminish
      ]);

      initEl = pkgs.writeText "init.el" ''
        ;;; init.el --- GNU Emacs with Doom Keymap & Devenv Integration -*- lexical-binding: t; -*-

        ;; --- 1. Performance & UI Cleanliness ---
        (setq gc-cons-threshold (* 50 1000 1000))
        (setq inhibit-startup-message t)
        (menu-bar-mode -1)
        (tool-bar-mode -1)
        (scroll-bar-mode -1)
        (global-display-line-numbers-mode 1)
        (setq display-line-numbers-type 'relative)
        (setq ring-bell-function 'ignore)
        (setq use-dialog-box nil)
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

        ;; --- 3. Noctalia Auto-Theme Integration ---
        (add-to-list 'custom-theme-load-path (expand-file-name "~/.config/emacs/"))
        (add-to-list 'custom-theme-load-path (expand-file-name "~/.config/emacs/themes/"))
        (add-to-list 'custom-theme-load-path (expand-file-name "~/.emacs.d/themes/"))
        (condition-case nil
            (load-theme 'noctalia t)
          (error
           (condition-case nil
               (load-theme 'doom-one t)
             (error nil))))

        ;; --- 4. Modeline & Icons ---
        (use-package doom-modeline
          :ensure nil
          :init (doom-modeline-mode 1)
          :config
          (setq doom-modeline-height 32)
          (setq doom-modeline-bar-width 4)
          (setq doom-modeline-icon t)
          (setq doom-modeline-env-version t))

        ;; --- 5. Ivy, Counsel & Swiper ---
        (use-package ivy
          :ensure nil
          :diminish
          :config
          (ivy-mode 1)
          (setq ivy-use-virtual-buffers t)
          (setq enable-recursive-minibuffers t))

        (use-package counsel
          :ensure nil
          :diminish
          :config (counsel-mode 1))

        (use-package which-key
          :ensure nil
          :init (which-key-mode 1)
          :config
          (setq which-key-idle-delay 0.3)
          (setq which-key-popup-type 'side-window))

        ;; --- 6. Evil Mode (Vim Emulation) ---
        (use-package evil
          :ensure nil
          :init
          (setq evil-want-integration t)
          (setq evil-want-keybinding nil)
          (setq evil-want-C-u-scroll t)
          (setq evil-undo-system 'undo-redo)
          :config
          (evil-mode 1))

        (use-package evil-collection
          :ensure nil
          :after evil
          :config
          (evil-collection-init))

        ;; --- 7. Direnv & Devenv Integration (Buffer-Local Toolchain) ---
        (use-package envrc
          :ensure nil
          :hook (after-init . envrc-global-mode))

        ;; --- 8. General.el with Full Doom Emacs Keybindings ---
        (use-package general
          :ensure nil
          :config
          (general-evil-setup t)
          (general-create-definer doom/leader-keys
            :states '(normal visual emacs)
            :keymaps 'override
            :prefix "SPC"
            :global-prefix "M-SPC")

          (doom/leader-keys
            ;; Root Leaders
            "SPC" '(counsel-find-file :which-key "find file")
            "."   '(counsel-find-file :which-key "find file")
            ","   '(ivy-switch-buffer :which-key "switch buffer")
            ":"   '(counsel-M-x :which-key "M-x")
            "/"   '(counsel-rg :which-key "search project")
            ";"   '(eval-expression :which-key "eval expression")
            "x"   '(kill-current-buffer :which-key "close buffer")

            ;; Buffers (SPC b)
            "b b" '(ivy-switch-buffer :which-key "switch buffer")
            "b d" '(kill-current-buffer :which-key "kill buffer")
            "b k" '(kill-current-buffer :which-key "kill buffer")
            "b s" '(save-buffer :which-key "save buffer")
            "b S" '(save-some-buffers :which-key "save all buffers")
            "b n" '(next-buffer :which-key "next buffer")
            "b p" '(previous-buffer :which-key "prev buffer")
            "b r" '(revert-buffer :which-key "reload buffer")

            ;; Files (SPC f)
            "f f" '(counsel-find-file :which-key "find file")
            "f s" '(save-buffer :which-key "save file")
            "f r" '(counsel-recentf :which-key "recent files")
            "f d" '(dired :which-key "dired")

            ;; Code & Compilation (SPC c)
            "c c" '(compile :which-key "compile project")
            "c C" '(recompile :which-key "recompile")

            ;; Docks & Open (SPC o)
            "o t" '(vterm-toggle :which-key "toggle vterm")
            "o p" '(dired-jump :which-key "file manager")
            "o s" '((lambda () (interactive) (find-file (expand-file-name "init.el" user-emacs-directory))) :which-key "open init.el")

            ;; Windows & Splits (SPC w)
            "w v" '(evil-window-vsplit :which-key "vertical split")
            "w s" '(evil-window-split :which-key "horizontal split")
            "w h" '(evil-window-left :which-key "window left")
            "w j" '(evil-window-down :which-key "window down")
            "w k" '(evil-window-up :which-key "window up")
            "w l" '(evil-window-right :which-key "window right")
            "w c" '(evil-window-delete :which-key "close window")
            "w m" '(delete-other-windows :which-key "maximize window")
            "w =" '(balance-windows :which-key "balance windows")

            ;; Quit (SPC q)
            "q q" '(save-buffers-kill-terminal :which-key "quit emacs")
            "q r" '(restart-emacs :which-key "restart emacs")))

        ;; --- 9. Org-Mode Configuration ---
        (use-package org
          :ensure nil
          :config
          (setq org-ellipsis " ▾")
          (setq org-hide-emphasis-markers t)
          (setq org-src-fontify-natively t)
          (setq org-src-tab-acts-natively t)
          (setq org-edit-src-content-indentation 0)
          (setq org-todo-keywords
                '((sequence "TODO(t)" "INPROGRESS(i)" "WAIT(w)" "|" "DONE(d)" "CANCELLED(c)")))
          (add-hook 'org-mode-hook 'org-bullets-mode)
          (add-hook 'org-mode-hook 'toc-org-mode)
          (add-hook 'org-mode-hook 'visual-line-mode))

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
        meta.description = "Hermetically wrapped GNU Emacs with Maple Mono NF, Doom keymap, and buffer-local Direnv/Devenv";
      };
    };
}
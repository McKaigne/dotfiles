{ self, inputs, ... }: {
  flake.nixosModules.emacs = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
    emacsPackage = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (epkgs: with epkgs; [
      meow
      vertico
      orderless
      marginalia
      consult
      which-key
    ]);
  in
  {
    environment.systemPackages = [ emacsPackage ];

    home-manager.users.${user} = {
      xdg.configFile."emacs/init.el".text = ''
        (setq inhibit-startup-message t
              ring-bell-function 'ignore
              visible-bell nil)
        (tool-bar-mode -1)
        (menu-bar-mode -1)
        (scroll-bar-mode -1)

        (set-face-attribute 'default nil :font "Lilex Nerd Font" :height 110)
        (set-face-attribute 'variable-pitch nil :font "IBM Plex Sans" :height 110)

        (global-display-line-numbers-mode t)
        (setq display-line-numbers-type 'relative)
        (setq-default cursor-type 'box)

        (vertico-mode 1)
        (setq completion-styles '(orderless basic))
        (marginalia-mode 1)
        (which-key-mode 1)

        (add-to-list 'custom-theme-load-path (expand-file-name "~/.config/emacs/themes"))
        (add-to-list 'custom-theme-load-path (expand-file-name "~/.config/emacs"))
        (condition-case nil
            (load-theme 'noctalia t)
          (error nil))

        (defun meow-setup ()
          (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
          (meow-motion-overwrite-define-key
           '("j" . meow-next)
           '("k" . meow-prev)
           '("<escape>" . ignore))
          (meow-leader-define-key
           '("f" . find-file)
           '("b" . switch-to-buffer)
           '("k" . kill-current-buffer)
           '("s" . save-buffer)
           '("q" . save-buffers-kill-terminal)
           '("1" . meow-digit-argument)
           '("2" . meow-digit-argument)
           '("3" . meow-digit-argument)
           '("4" . meow-digit-argument)
           '("5" . meow-digit-argument))
          (meow-normal-define-key
           '("0" . meow-expand-0)
           '("9" . meow-expand-9)
           '("8" . meow-expand-8)
           '("7" . meow-expand-7)
           '("6" . meow-expand-6)
           '("5" . meow-expand-5)
           '("4" . meow-expand-4)
           '("3" . meow-expand-3)
           '("2" . meow-expand-2)
           '("1" . meow-expand-1)
           '("-" . negative-argument)
           '(";" . meow-reverse)
           '("," . meow-inner-of-thing)
           '("." . meow-bounds-of-thing)
           '("[" . meow-beginning-of-thing)
           '("]" . meow-end-of-thing)
           '("a" . meow-append)
           '("A" . meow-open-below)
           '("b" . meow-back-word)
           '("B" . meow-back-symbol)
           '("c" . meow-change)
           '("d" . meow-delete)
           '("D" . meow-backward-delete)
           '("e" . meow-next-word)
           '("E" . meow-next-symbol)
           '("f" . meow-find)
           '("g" . meow-cancel-selection)
           '("G" . meow-grab)
           '("h" . meow-left)
           '("H" . meow-left-expand)
           '("i" . meow-insert)
           '("I" . meow-open-above)
           '("j" . meow-next)
           '("J" . meow-next-expand)
           '("k" . meow-prev)
           '("K" . meow-prev-expand)
           '("l" . meow-right)
           '("L" . meow-right-expand)
           '("m" . meow-join)
           '("n" . meow-search)
           '("o" . meow-block)
           '("O" . meow-to-block)
           '("p" . meow-yank)
           '("q" . meow-quit)
           '("r" . meow-replace)
           '("R" . meow-swap-grab)
           '("s" . meow-kill)
           '("t" . meow-till)
           '("u" . meow-undo)
           '("U" . meow-undo-in-selection)
           '("v" . meow-visit)
           '("w" . meow-mark-word)
           '("W" . meow-mark-symbol)
           '("x" . meow-line)
           '("X" . meow-goto-line)
           '("y" . meow-save)
           '("Y" . meow-sync-grab)
           '("z" . meow-pop-selection)
           '("'" . repeat)
           '("<escape>" . meow-cancel-selection)))

        (require 'meow)
        (meow-setup)
        (meow-global-mode 1)
      '';
    };
  };
}

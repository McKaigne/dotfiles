{ self, inputs, ... }: {
  flake.nixosModules.tmux = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;

    tmuxConf = ''
      # ------------------------------------------------------------------------
      # Core Settings
      # ------------------------------------------------------------------------
      set -g prefix C-b
      unbind C-b
      bind C-b send-prefix

      set -g default-terminal "tmux-256color"
      set -as terminal-features "*:RGB"
      set -s escape-time 0
      set -g focus-events on
      set -g mouse on
      set -g history-limit 100000

      # Base 1 Indexing & Title Tracking
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g set-titles on
      set -g set-titles-string "#T"

      # Quick Config Reload
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; display-message 'tmux.conf reloaded'

      # ------------------------------------------------------------------------
      # OSC 52 Clipboard & Vi Copy Mode
      # ------------------------------------------------------------------------
      set -s set-clipboard on
      set -as terminal-features ',tmux-256color:clipboard'

      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'Space' send -X clear-selection
      bind-key -T copy-mode-vi 'y' send -X copy-pipe "${pkgs.wl-clipboard}/bin/wl-copy"

      # ------------------------------------------------------------------------
      # Statusline Structure & Dynamic Theme Sourcing (Noctalia Authority)
      # ------------------------------------------------------------------------
      set -g status on
      set -g status-position top
      set -g status-justify left
      set -g status-interval 2
      set -g status-left-length 80
      set -g status-right ""
      set -g window-status-separator "  "

      # Sourced quietly from Noctalia dynamic template engine
      source-file -q ~/.config/tmux/themes/noctalia.conf

      # ------------------------------------------------------------------------
      # Window Creation & Pane Splits (Prefix-guarded: Zero Helix Collisions)
      # ------------------------------------------------------------------------
      bind c new-window -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind _ split-window -v -c "#{pane_current_path}"
      bind x kill-pane
      bind X kill-window

      # ------------------------------------------------------------------------
      # Unprefixed Alt Navigation Suite (Safe for Helix Multi-cursor & Treesitter)
      # ------------------------------------------------------------------------
      # Pane Navigation
      bind-key -n M-h select-pane -L
      bind-key -n M-j select-pane -D
      bind-key -n M-k select-pane -U
      bind-key -n M-l select-pane -R

      # Alt+0-9 Window Navigation (Auto-creates window if non-existent)
      bind-key -n M-1 if-shell "tmux select-window -t :1" "" "new-window -t :1"
      bind-key -n M-2 if-shell "tmux select-window -t :2" "" "new-window -t :2"
      bind-key -n M-3 if-shell "tmux select-window -t :3" "" "new-window -t :3"
      bind-key -n M-4 if-shell "tmux select-window -t :4" "" "new-window -t :4"
      bind-key -n M-5 if-shell "tmux select-window -t :5" "" "new-window -t :5"
      bind-key -n M-6 if-shell "tmux select-window -t :6" "" "new-window -t :6"
      bind-key -n M-7 if-shell "tmux select-window -t :7" "" "new-window -t :7"
      bind-key -n M-8 if-shell "tmux select-window -t :8" "" "new-window -t :8"
      bind-key -n M-9 if-shell "tmux select-window -t :9" "" "new-window -t :9"
      bind-key -n M-0 if-shell "tmux select-window -t :10" "" "new-window -t :10"

      # Window Cycling
      bind-key -n M-H previous-window
      bind-key -n M-L next-window

      # Session Cycling
      bind-key -n M-J switch-client -p
      bind-key -n M-K switch-client -n

      # Window & Session Renaming
      bind , command-prompt -I "#W" "rename-window -- '%%'"
      bind $ command-prompt -I "#S" "rename-session -- '%%'"

      # Repeatable Pane Resizing
      bind-key -r -T prefix Up resize-pane -U 5
      bind-key -r -T prefix Down resize-pane -D 5
      bind-key -r -T prefix Left resize-pane -L 5
      bind-key -r -T prefix Right resize-pane -R 5
      bind-key -n -r M-Up resize-pane -U 5
      bind-key -n -r M-Down resize-pane -D 5
      bind-key -n -r M-Left resize-pane -L 5
      bind-key -n -r M-Right resize-pane -R 5

      # Mark & Join Panes
      bind-key -n M-m select-pane -m
      bind-key -n M-b join-pane

      # Zoom & Layouts
      bind-key -n M-z resize-pane -Z
      bind-key -n M-f resize-pane -Z
      bind-key m resize-pane -Z
      bind-key M-4 select-layout main-vertical
      bind-key -n M-O select-pane -t :.+

      # ------------------------------------------------------------------------
      # Floating Tool Popups (Overlay bridges accessible while inside Helix)
      # ------------------------------------------------------------------------
      bind-key g display-popup -d "#{pane_current_path}" -w 85% -h 85% -E "${pkgs.lazygit}/bin/lazygit"
      bind-key t display-popup -d "#{pane_current_path}" -w 80% -h 80% -E "${pkgs.btop}/bin/btop"
      bind-key p display-popup -d "#{pane_current_path}" -w 80% -h 80% -E -e TERM=tmux-256color "${pkgs.zsh}/bin/zsh"

      # FZF Pickers
      bind-key C-j display-popup -E "${pkgs.tmux}/bin/tmux list-sessions -F '#{session_name}' | ${pkgs.fzf}/bin/fzf --reverse | xargs ${pkgs.tmux}/bin/tmux switch-client -t"
      bind-key C-k display-popup -E "${pkgs.tmux}/bin/tmux list-windows -a -F '#{session_name}:#{window_index} - #{window_name}' | ${pkgs.fzf}/bin/fzf --reverse | cut -d' ' -f1 | xargs ${pkgs.tmux}/bin/tmux switch-client -t"
      bind-key C-v display-popup -E "${pkgs.tmux}/bin/tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}' | grep -E 'hx|helix|nvim|vim' | ${pkgs.fzf}/bin/fzf --reverse | awk '{print \$1}' | xargs -I{} ${pkgs.tmux}/bin/tmux switch-client -t {}"
    '';
  in
  {
    environment.systemPackages = with pkgs; [
      tmux
      nnn
      fzf
      btop
      wl-clipboard
    ];

    home-manager.users.${user} = {
      xdg.configFile."tmux/tmux.conf" = {
        text = tmuxConf;
        force = true;
      };
    };
  };
}

{ self, inputs, ... }: {
  flake.nixosModules.tmux = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;

    tmuxConf = ''
      # General Settings
      set -g prefix C-b
      unbind C-b
      bind C-b send-prefix

      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -s escape-time 0
      set -g focus-events on
      set -g mouse on
      set -g history-limit 50000

      # Base 1 Indexing
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      # ------------------------------------------------------------------------
      # Solarized Osaka "Dotbar" Statusline
      # ------------------------------------------------------------------------
      set -g status-position top
      set -g status-interval 2
      set -g status-style "bg=#00141a,fg=#839496"

      set -g status-left-length 40
      set -g status-left "#[fg=#b58900,bold]● #S #[fg=#073642]• "

      set -g status-right-length 60
      set -g status-right "#[fg=#586e75]#{?client_prefix,#[fg=#2aa198,bold]PREFIX ,}#{?window_zoomed_flag,#[fg=#dc322f,bold]ZOOM ,}#[fg=#073642]• #[fg=#2aa198]⌂ "

      setw -g window-status-separator " "
      setw -g window-status-format "#[fg=#586e75]○ #I #W"
      setw -g window-status-current-format "#[fg=#2aa198,bold]● #I #W"

      set -g pane-border-style "fg=#073642"
      set -g pane-active-border-style "fg=#2aa198"
      set -g popup-border-style "fg=#2aa198"

      # ------------------------------------------------------------------------
      # Keybindings (Alt combos with no prefix)
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

      # Window / Pane Creation & Killing
      bind-key -n M-x kill-pane
      bind-key -n M-X kill-window
      bind-key -n M-c new-window -c "#{pane_current_path}"
      bind-key -n M-, command-prompt -I "#W" "rename-window -- '%%'"
      bind-key -n M-$ command-prompt -I "#S" "rename-session -- '%%'"
      bind-key -n M-n split-window -v -c "#{pane_current_path}"
      bind-key -n M-v split-window -h -c "#{pane_current_path}"

      # Floating Popups
      bind-key -n M-e display-popup -E -w 80% -h 80% "${pkgs.nnn}/bin/nnn"
      bind-key -n M-t display-popup -E -w 80% -h 80% "${pkgs.btop}/bin/btop"

      # Repeatable Pane Resizing
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
      bind-key M-4 select-layout main-vertical
      bind-key -n M-O select-pane -t :.+

      # Prefix FZF Pickers
      bind-key C-j display-popup -E "${pkgs.tmux}/bin/tmux list-sessions -F '#{session_name}' | ${pkgs.fzf}/bin/fzf --reverse | xargs ${pkgs.tmux}/bin/tmux switch-client -t"
      bind-key C-k display-popup -E "${pkgs.tmux}/bin/tmux list-windows -a -F '#{session_name}:#{window_index} - #{window_name}' | ${pkgs.fzf}/bin/fzf --reverse | cut -d' ' -f1 | xargs ${pkgs.tmux}/bin/tmux switch-client -t"
      bind-key C-v display-popup -E "${pkgs.tmux}/bin/tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}' | grep -E 'hx|nvim|vim' | ${pkgs.fzf}/bin/fzf --reverse | awk '{print \$1}' | xargs -I{} ${pkgs.tmux}/bin/tmux switch-client -t {}"
    '';
  in
  {
    environment.systemPackages = with pkgs; [
      tmux
      nnn
      fzf
      btop
    ];

    home-manager.users.${user} = {
      xdg.configFile."tmux/tmux.conf" = {
        text = tmuxConf;
        force = true;
      };
    };
  };
}

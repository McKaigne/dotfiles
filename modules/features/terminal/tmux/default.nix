{ self, inputs, ... }: {
  flake.nixosModules.tmux =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      p = config.palette;

      tmuxConf = ''
        set -g prefix C-Space
        unbind C-b
        bind C-Space send-prefix

        set -g default-terminal "tmux-256color"
        set -as terminal-features "*:RGB"
        set -s escape-time 0
        set -g focus-events on
        set -g mouse on
        set -g history-limit 100000

        set -g base-index 1
        setw -g pane-base-index 1
        set -g renumber-windows on
        set -g set-titles on
        set -g set-titles-string "#T"

        unbind r
        bind r source-file ~/.config/tmux/tmux.conf \; display-message 'tmux.conf reloaded'

        set -s set-clipboard on
        set -as terminal-features ',tmux-256color:clipboard'

        set-window-option -g mode-keys vi
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'Space' send -X clear-selection
        bind-key -T copy-mode-vi 'y' send -X copy-pipe "${pkgs.wl-clipboard}/bin/wl-copy"

        set -g status on
        set -g status-position top

        set -g @tmux-dotbar-bg "default"
        set -g @tmux-dotbar-fg "${p.surface2}"
        set -g @tmux-dotbar-fg-current "${p.text}"
        set -g @tmux-dotbar-fg-session "${p.mauve}"
        set -g @tmux-dotbar-fg-prefix "${p.red}"
        set -g @tmux-dotbar-bold-current-window true

        set -g pane-border-style "fg=${p.surface0},bg=default"
        set -g pane-active-border-style "fg=${p.mauve},bg=default"
        set -g popup-border-style "fg=${p.mauve},bg=default"

        run-shell ${pkgs.tmuxPlugins.dotbar}/share/tmux-plugins/dotbar/dotbar.tmux

        bind c new-window -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind | split-window -h -c "#{pane_current_path}"
        bind _ split-window -v -c "#{pane_current_path}"
        bind x kill-pane
        bind X kill-window

        bind-key -n M-h select-pane -L
        bind-key -n M-j select-pane -D
        bind-key -n M-k select-pane -U
        bind-key -n M-l select-pane -R

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

        bind-key -n M-H previous-window
        bind-key -n M-L next-window
        bind-key -n M-J switch-client -p
        bind-key -n M-K switch-client -n

        bind , command-prompt -I "#W" "rename-window -- '%%'"
        bind $ command-prompt -I "#S" "rename-session -- '%%'"

        bind-key -r -T prefix Up resize-pane -U 5
        bind-key -r -T prefix Down resize-pane -D 5
        bind-key -r -T prefix Left resize-pane -L 5
        bind-key -r -T prefix Right resize-pane -R 5
        bind-key -n -r M-Up resize-pane -U 5
        bind-key -n -r M-Down resize-pane -D 5
        bind-key -n -r M-Left resize-pane -L 5
        bind-key -n -r M-Right resize-pane -R 5

        bind-key -n M-m select-pane -m
        bind-key -n M-b join-pane
        bind-key -n M-z resize-pane -Z
        bind-key -n M-f resize-pane -Z
        bind-key m resize-pane -Z
        bind-key M-4 select-layout main-vertical
        bind-key -n M-O select-pane -t :.+

        bind-key g display-popup -d "#{pane_current_path}" -w 85% -h 85% -E "${pkgs.lazygit}/bin/lazygit"
        bind-key t display-popup -d "#{pane_current_path}" -w 80% -h 80% -E "${pkgs.btop}/bin/btop"
        bind-key p display-popup -d "#{pane_current_path}" -w 80% -h 80% -E -e TERM=tmux-256color "${pkgs.zsh}/bin/zsh"

        bind-key C-j display-popup -E "${pkgs.tmux}/bin/tmux list-sessions -F '#{session_name}' | ${pkgs.fzf}/bin/fzf --reverse | xargs -r ${pkgs.tmux}/bin/tmux switch-client -t"
        bind-key C-k display-popup -E "${pkgs.tmux}/bin/tmux list-windows -a -F '#{session_name}:#{window_index} - #{window_name}' | ${pkgs.fzf}/bin/fzf --reverse | cut -d' ' -f1 | xargs -r ${pkgs.tmux}/bin/tmux switch-client -t"
        bind-key C-v display-popup -E "${pkgs.tmux}/bin/tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}' | grep -E 'nvim|vim' | ${pkgs.fzf}/bin/fzf --reverse | awk '{print $1}' | xargs -r -I{} ${pkgs.tmux}/bin/tmux switch-client -t {}"

      '';
    in
    {
      environment.systemPackages = [
        pkgs.tmux
      ];

      home-manager.users.${user} = {
        xdg.configFile."tmux/tmux.conf" = {
          text = tmuxConf;
          force = true;
        };

      };
    };
}

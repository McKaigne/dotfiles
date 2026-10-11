{ self, inputs, ... }: {
  flake.nixosModules.tmux = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;

    dotbarScript = pkgs.writeScript "tmux-dotbar" ''
      #!${pkgs.bash}/bin/bash
      export PATH="${lib.makeBinPath [ pkgs.tmux pkgs.gnugrep pkgs.gnused pkgs.coreutils ]}:$PATH"

      get_tmux_option() {
        local option="$1"
        local default_value="$2"
        local option_value
        option_value=$(tmux show-options -gqv "$option")
        [ -n "$option_value" ] && echo "$option_value" || echo "$default_value"
      }

      # Colors
      bg=$(get_tmux_option "@tmux-dotbar-bg" '#0B0E14')
      fg=$(get_tmux_option "@tmux-dotbar-fg" '#475266')
      fg_current=$(get_tmux_option "@tmux-dotbar-fg-current" '#BFBDB6')
      fg_session=$(get_tmux_option "@tmux-dotbar-fg-session" '#565B66')
      fg_prefix=$(get_tmux_option "@tmux-dotbar-fg-prefix" '#95E6CB')

      # Options
      bold_status=$(get_tmux_option "@tmux-dotbar-bold-status" false)
      bold_current_window=$(get_tmux_option "@tmux-dotbar-bold-current-window" false)
      bold_session=$(get_tmux_option "@tmux-dotbar-bold-session" false)
      bold_status_right=$(get_tmux_option "@tmux-dotbar-bold-status-right" false)
      rounded=$(get_tmux_option "@tmux-dotbar-rounded" true)
      status=$(get_tmux_option "@tmux-dotbar-position" "bottom")
      justify=$(get_tmux_option "@tmux-dotbar-justify" "absolute-centre")
      left_state=$(get_tmux_option "@tmux-dotbar-left" true)
      right_state=$(get_tmux_option "@tmux-dotbar-right" false)

      # Status Components
      session_text=$(get_tmux_option "@tmux-dotbar-session-text" " #S ")
      session_position=$(get_tmux_option "@tmux-dotbar-session-position" "left")
      time_text=$(get_tmux_option "@tmux-dotbar-status-right-text" " %H:%M ")

      session_bold_attr="nobold"
      [ "$bold_session" = true ] && session_bold_attr="bold"

      status_right_bold_attr="nobold"
      [ "$bold_status_right" = true ] && status_right_bold_attr="bold"

      prefix_bold_attr="bold"
      if [ "$bold_status" = true ]; then
        session_bold_attr="bold"
        status_right_bold_attr="bold"
        prefix_bold_attr="nobold"
      fi

      if [ "$rounded" = "true" ]; then
        edge_left='�'
        edge_right='�'
        if [ "''${#session_text}" -gt 2 ]; then
          session_text_inner="''${session_text:1:''${#session_text}-2}"
        else
          session_text_inner="$session_text"
        fi
        session_component="#[bg=$bg,fg=$fg_session,$session_bold_attr]#{?client_prefix,#[fg=$fg_prefix]$edge_left,$session_text}#[bg=$fg_prefix,fg=$bg,$prefix_bold_attr]#{?client_prefix,$session_text_inner,}#[bg=$bg,fg=''${fg_session},$session_bold_attr]#{?client_prefix,#[fg=$fg_prefix]$edge_right,}"
      else
        session_component="#[bg=$bg,fg=$fg_session,$session_bold_attr]#{?client_prefix,,$session_text}#[bg=$fg_prefix,fg=$bg,$prefix_bold_attr]#{?client_prefix,$session_text,}#[bg=$bg,fg=''${fg_session},$session_bold_attr]"
      fi
      time_component="#[bg=$bg,fg=$fg_session,$status_right_bold_attr]$time_text#[bg=$bg,fg=''${fg_session},$status_right_bold_attr]"

      # Build Default Status Strings
      if [ "$session_position" = "right" ]; then
        default_left=""
        [ "$right_state" = "true" ] && default_right="$time_component$session_component" || default_right="$session_component"
      else
        default_left="$session_component"
        [ "$right_state" = "true" ] && default_right="$time_component" || default_right=""
      fi

      status_left=$(get_tmux_option "@tmux-dotbar-status-left" "$default_left")
      status_right=$(get_tmux_option "@tmux-dotbar-status-right" "$default_right")

      [ "$left_state" != "true" ] && status_left=""
      ([ "$right_state" != "true" ] && [ "$session_position" != "right" ]) && status_right=""

      # Window Format & SSH
      base_window_format=$(get_tmux_option "@tmux-dotbar-window-status-format" ' #W ')
      ssh_enabled=$(get_tmux_option "@tmux-dotbar-ssh-enabled" true)

      if [ "$ssh_enabled" = true ]; then
        ssh_icon=$(get_tmux_option "@tmux-dotbar-ssh-icon" '󰌘')
        ssh_icon_only=$(get_tmux_option "@tmux-dotbar-ssh-icon-only" false)
        if [ "$ssh_icon_only" = true ]; then
          ssh_window_format=" ''${ssh_icon}''${base_window_format}"
        else
          ssh_window_format=" ''${ssh_icon} #(host=\$(echo '#{pane_title}' | sed 's/^ssh //; s/ .*//; s/.*@//; s/:.*//'); if echo \"\$host\" | grep -qE '^[0-9.]+\$|^[0-9]'; then echo '#W'; else echo \"\$host\"; fi | cut -c1-20) "
        fi
        window_status_format="#{?#{==:#{pane_current_command},ssh},''${ssh_window_format},''${base_window_format}}"
      else
        window_status_format="''${base_window_format}"
      fi

      window_status_separator=$(get_tmux_option "@tmux-dotbar-window-status-separator" ' • ')
      maximized_pane_icon=$(get_tmux_option "@tmux-dotbar-maximized-icon" '󰊓')
      show_maximized_icon_for_all_tabs=$(get_tmux_option "@tmux-dotbar-show-maximized-icon-for-all-tabs" false)

      # Apply Options
      tmux set-option -g status-position "$status"
      tmux set-option -g status-justify "$justify"
      tmux set-option -g status-left "$status_left"
      tmux set-option -g status-right "$status_right"
      tmux set-window-option -g window-status-separator "$window_status_separator"
      tmux set-option -g window-status-style "bg=''${bg},fg=''${fg}"
      tmux set-option -g window-status-format "$window_status_format"
      [ "$show_maximized_icon_for_all_tabs" = true ] && tmux set-option -g window-status-format "''${window_status_format}#{?window_zoomed_flag,''${maximized_pane_icon},}"

      status_style="bg=''${bg},fg=''${fg}"
      [ "$bold_status" = true ] && status_style="$status_style,bold"
      tmux set-option -g status-style "$status_style"

      tmux set-option -g window-status-bell-style "bg=''${fg_prefix},fg=''${bg},bold"
      tmux set-option -g window-status-activity-style "bg=''${fg_current},fg=''${bg}"

      current_format="#[bg=''${bg},fg=''${fg_current}]''${window_status_format}#[fg=#2aa198,bg=''${bg}]#{?window_zoomed_flag,''${maximized_pane_icon},}#[fg=''${bg},bg=default]"
      [ "$bold_current_window" = true ] && current_format="#[bg=''${bg},fg=''${fg_current},bold]''${window_status_format}#[fg=#2aa198,bg=''${bg}]#{?window_zoomed_flag,''${maximized_pane_icon},}#[fg=''${bg},bg=default]"
      tmux set-option -g window-status-current-format "$current_format"
    '';

    tmuxConf = ''
      # ------------------------------------------------------------------------
      # General Settings
      # ------------------------------------------------------------------------
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
      # Dotbar Configuration (100% Transparency & Solarized Osaka)
      # ------------------------------------------------------------------------
      set -g @tmux-dotbar-bg "default"
      set -g @tmux-dotbar-fg "#586e75"
      set -g @tmux-dotbar-fg-current "#2aa198"
      set -g @tmux-dotbar-fg-session "#b58900"
      set -g @tmux-dotbar-fg-prefix "#268bd2"
      set -g @tmux-dotbar-position "top"
      set -g @tmux-dotbar-justify "absolute-centre"
      set -g @tmux-dotbar-rounded "true"
      set -g @tmux-dotbar-window-status-separator " • "
      set -g @tmux-dotbar-session-text " #S "
      set -g @tmux-dotbar-status-right-text " %H:%M "
      set -g @tmux-dotbar-right true

      # Transparent Borders
      set -g pane-border-style "fg=#073642,bg=default"
      set -g pane-active-border-style "fg=#2aa198,bg=default"
      set -g popup-border-style "fg=#2aa198,bg=default"

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

      # Execute Dotbar Script
      run-shell "${dotbarScript}"
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

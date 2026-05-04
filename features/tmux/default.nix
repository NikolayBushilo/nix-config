{pkgs, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user}.programs.tmux = {
        enable = true;
        prefix = "C-SPACE";

        keyMode = "vi";
        newSession = true;
        baseIndex = 1;
        focusEvents = true;
        escapeTime = 0;
        mouse = true;
        historyLimit = 10000;

        plugins = with pkgs.tmuxPlugins; [
            vim-tmux-navigator
            resurrect
            continuum
        ];

        extraConfig = ''
            set -g focus-events on

            set -g status-style "bg=default,fg=white"

            set -g status-left ""
            set -g status-right "#[fg=white]#S"

            set -g window-status-style "fg=grey"
            set -g window-status-format " #W"

            set -g window-status-current-style "fg=black,bg=magenta,nobold"
            set -g window-status-current-format \
            "#{?window_zoomed_flag, 🔍 ,}#W"

            set -g window-status-bell-style "fg=red,nobold"

            set -g renumber-windows on

            bind | split-window -h -c "#{pane_current_path}"
            bind - split-window -v -c "#{pane_current_path}"
            bind m resize-pane -Z
        '';
    };

}

{config, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint
    programs.zsh = {
        enable = true;
    };

    # Home-manager entrypoint
    home-manager.users.${user}.programs.zsh = {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;
        shellAliases = {
            rebuild="sudo nixos-rebuild switch --flake ~/Sources/nix-config/.#${config.networking.hostName}";
            ls="eza";
            grep="rg";
            cat="bat";
            v="nvim";
            tn="tmux new-session -s";
            tl="tmux list-sessions";
            ta="tmux attach-session";
        };
        initContent = ''
            eval "$(direnv hook zsh)"
            export DIRENV_LOG_FORMAT=""
            export NIX_DIRENV_LOG_FORMAT=""
            precmd() {
            if [[ -n "$IN_NIX_SHELL" ]]; then
            PROMPT="%F{blue}%n@%m %~ %# %f"
            else
            PROMPT="%n@%m %~ %# "
            fi
            }
        '';
  };

}

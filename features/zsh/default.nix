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
        };
        # initExtra = ''
        #     PROMPT="\[\033[38;2;199;60;3m\]\w > \[\033[0m\]"
        # '';
  };

}

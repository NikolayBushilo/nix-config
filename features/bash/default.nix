{config, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user}.programs.bash = {
        enable = true;
        initExtra = ''
         PS1="\[\033[38;2;199;60;3m\]\w > \[\033[0m\]"
       '';
        shellAliases = {
          rebuild="sudo nixos-rebuild switch --flake ~/Sources/nix-config/.#${config.networking.hostName}";
          ls="eza";
          cd="z";
          cdi="zi";
          grep="rg";
          cat="bat";
        };
    };

}

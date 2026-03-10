{config, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint
    programs.steam = {
        enable = true;
    };
    # Home-manager entrypoint
    home-manager.users.${user} = {
    };

}

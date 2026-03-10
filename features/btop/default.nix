{config, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user}.programs.btop = {
        enable = true;
    };

}

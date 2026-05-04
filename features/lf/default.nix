{config, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user}.programs.lf = {
        enable = true;
        settings = {
            relativenumber = true;
            hidden = true;
            icons = true;
            mouse = true;
        };
    };

}

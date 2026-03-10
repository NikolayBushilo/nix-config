{config, pkgs, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user}.programs.obsidian = {
        enable = true;
    };

}

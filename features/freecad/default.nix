{config, pkgs, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user} = {
        home.packages = with pkgs; [
            freecad
        ];
    };

}

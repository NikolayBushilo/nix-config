{config, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user}.programs.rofi = {
        enable = true;
        modes = [
          "drun"
        ];
        location = "center";
    };

}

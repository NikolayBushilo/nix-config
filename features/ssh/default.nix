{config, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user}.programs.ssh = {
        enable = true;
        matchBlocks = {
            ms-01 = {
                hostname = "10.1.10.10";
                user = "niko";
                port = 22;
            };

            vm-edge = {
                hostname = "10.1.70.10";
                user = "niko";
                port = 22;
                identityFile = "~/.ssh/id_ed25519_personal";
            };
        };
    };
}

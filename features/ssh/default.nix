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

            vm-edge = {
                hostname = "10.1.0.71";
                user = "niko";
                port = 22;
                identityFile = "~/.ssh/id_ed25519_personal";
            };

            vm-core = {
                hostname = "10.1.0.72";
                user = "niko";
                port = 22;
                identityFile = "~/.ssh/id_ed25519_personal";
            };

            vm-private = {
                hostname = "10.1.0.73";
                user = "niko";
                port = 22;
                identityFile = "~/.ssh/id_ed25519_personal";
            };

            vm-public = {
                hostname = "10.1.0.74";
                user = "niko";
                port = 22;
                identityFile = "~/.ssh/id_ed25519_personal";
            };

            vm-storage = {
                hostname = "10.1.0.75";
                user = "niko";
                port = 22;
                identityFile = "~/.ssh/id_ed25519_personal";
            };
            # ms-01 = {
            #     hostname = "10.1.0.10";
            #     user = "niko";
            #     port = 22;
            #     identityFile = "~/.ssh/id_ed25519_personal";
            # };

            # vm-edge = {
            #     hostname = "ssh.bushilo.com";
            #     user = "niko";
            #     port = 22;
            #     identityFile = "~/.ssh/id_ed25519_personal";
            #     proxyCommand = "cloudflared access ssh --hostname %h";
            # };
        };
    };
}

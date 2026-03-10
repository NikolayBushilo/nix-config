{config, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user}.programs.git = {
        enable = true;
        settings = {
            user = {
                name = "Nikolay Bushilo";
                email = "github@bushilo.com";
            };
            init.defaultBranch = "main";
        };
    };

}

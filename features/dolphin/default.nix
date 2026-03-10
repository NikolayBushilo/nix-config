{config, pkgs, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint

    # Home-manager entrypoint
    home-manager.users.${user} = {
        home.packages = with pkgs; [
            # Dolphin Graphical File Manager 
            kdePackages.dolphin
            kdePackages.qtsvg # Icons for Dolphin
            # Needed for network mount in Dolphin
            kdePackages.kio
            kdePackages.kio-fuse
            kdePackages.kio-extras
        ];
    };

}

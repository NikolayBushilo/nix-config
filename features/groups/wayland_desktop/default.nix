{config, pkgs, ...}:
{

    # NixOS entrypoint
    imports = [
        ../../hyprland
        ../../waybar
        ../../kitty
    ];

    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

}

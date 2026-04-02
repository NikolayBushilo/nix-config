{config, pkgs, ...}:
{

    # NixOS entrypoint
    imports = [
        ../../hyprland
        ../../waybar
        ../../kitty
        ../../brightnessctl
    ];

    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

}

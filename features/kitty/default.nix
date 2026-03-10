{config, ...}:
let
    user = "niko";
in
{

    # Home-manager entrypoint
    home-manager.users.${user}.programs.kitty = {
        enable = true;
        settings = {
            font_family="JetBrains Mono Medium";
            font_size=15;
            window_margin_width=4;
            shell_integration=false;
            themeFile = "gruvbox-dark";
        };
    };
}

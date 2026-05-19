{config, lib, ...}:
let
    user = "niko";
    c = config.colorScheme.palette;
in
{

    # Home-manager entrypoint
    home-manager.users.${user}.programs.kitty = lib.mkDefault {
        enable = true;
        # themeFile = "citylights";
        settings = {
            font_family="JetBrains Mono Medium";
            # font_family="ToshibaSat 8x16";
            font_size= 15;
            window_margin_width=4;
            shell_integration=false;

            # The basic colors
            foreground = "#${c.base04}";
            background = "#${c.base00}";
            selection_foreground = "#${c.base05}";
            selection_background = "#${c.base01}";

            # Cursor colors
            cursor = "#${c.base04}";
            cursor_text_color = "#${c.base00}";

            # kitty window border colors
            active_border_color = "#${c.base09}";
            inactive_border_color = "#${c.base02}";

            # Tab bar colors
            active_tab_background = "#${c.base00}";
            active_tab_foreground = "#${c.base04}";
            inactive_tab_background = "#${c.base02}";
            inactive_tab_foreground = "#${c.base00}";

            # The basic 16 colors
            # black
            color0 = "#${c.base06}";
            color8 = "#${c.base02}";

            # red
            color1 = "#${c.base08}";
            color9 = "#${c.base09}";

            # green
            color2 = "#${c.base0B}";
            color10 = "#${c.base05}";

            # yellow
            color3 = "#${c.base0A}";
            color11 = "#${c.base04}";

            # blue
            color4 = "#${c.base0D}";
            color12 = "#${c.base03}";

            # magenta
            color5 = "#${c.base0F}";
            color13 = "#${c.base0E}";

            # cyan
            color6 = "#${c.base0C}";
            color14 = "#${c.base02}";

            # white
            color7 = "#${c.base01}";
            color15 = "#${c.base00}";
        };
    };
}

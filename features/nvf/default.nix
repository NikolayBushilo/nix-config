{config, inputs, ...}:
let
    user = "niko";
in
{

    # NixOS entrypoint
    # xdg.desktopFile."nvim.desktop".text = ''
    #     [Desktop Entry]
    #     Name=Neovim
    #     Comment=Edit text files in Neovim terminal editor
    #     Exec=alacritty -e nvim %f
    #     Terminal=false
    #     Type=Application
    #     MimeType=text/plain;
    #     Categories=Utility;TextEditor;
    #     StartupNotify=true
    # '';

    # Home-manager entrypoint
    home-manager.users.${user} = { config, ... }:
        let
            c = config.colorScheme.palette;
        in {
            imports = [
                inputs.nix-colors.homeManagerModules.default
                inputs.nvf.homeManagerModules.nvf
            ];

            colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-medium;

            programs.nvf = {
                enable = true;
                enableManpages = true;
                defaultEditor = true;

                settings.vim = {
                    lineNumberMode = "relNumber";
                    options = {
                        cursorline = true;
                        colorcolumn = "80";
                        tabstop = 4;
                        shiftwidth = 4;
                        softtabstop = 4;
                    };
                    theme = {
                        enable = true;
                        name = "base16";
                        transparent = false;

                        base16-colors = {
                            base00 = c.base00;
                            #base00 = "#282828";
                            base01 = "#${c.base01}";
                            base02 = "#${c.base02}";
                            base03 = "#${c.base03}";
                            base04 = "#${c.base04}";
                            base05 = "#${c.base05}";
                            base06 = "#${c.base06}";
                            base07 = "#${c.base07}";
                            base08 = "#${c.base08}";
                            base09 = "#${c.base09}";
                            base0A = "#${c.base0A}";
                            base0B = "#${c.base0B}";
                            base0C = "#${c.base0C}";
                            base0D = "#${c.base0D}";
                            base0E = "#${c.base0E}";
                            base0F = "#${c.base0F}";
                        };
                    };
                    tabline.nvimBufferline = {
                        enable = false;
                    };
                    keymaps = [
                        {
                            mode = "n";
                            key = "<Tab>";
                            action = ">>";
                        }
                        {
                            mode = "n";
                            key = "<S-Tab>";
                            action = "<<";
                        }
                        {
                            mode = "v";
                            key = "<Tab>";
                            action = ">gv";
                        }
                        {
                            mode = "v";
                            key = "<S-Tab>";
                            action = "<gv";
                        }
                    ];
                };
            };
        };
}

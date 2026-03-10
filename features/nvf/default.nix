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
    home-manager.users.${user} = {
        imports = [
            inputs.nvf.homeManagerModules.nvf
        ];
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
                    enable = false;
                    name = "solarized";
                    style = "light";
                    transparent = true;
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

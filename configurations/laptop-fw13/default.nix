#----------------------------------------------------------------                     
#    ____                                   __     _______
#   / __/______ ___ _  ___ _    _____  ____/ /__  <  /_  /
#  / _// __/ _ `/  ' \/ -_) |/|/ / _ \/ __/  '_/  / //_ < 
# /_/ /_/  \_,_/_/_/_/\__/|__,__/\___/_/ /_/\_\  /_/____/ 
#                                                        
#----------------------------------------------------------------
#  License : MIT
#  Author  : Nikolay Bushilo 
#  URL     : COMING SOON 
#  Info    : My personal laptop config
#----------------------------------------------------------------
#  Index:
#   1. Flake Stuff..............................................
#   2. Host Configuration.......................................
#     2.1 Sops..................................................
#     2.3 Networking............................................
#     2.4 System Packages.......................................
#     2.5 Services..............................................
#     2.6 Misc..................................................
#   3. Home-manager Configuration...............................
#----------------------------------------------------------------

#----------------------------------------------------------------
# 1. Flake Stuff
#----------------------------------------------------------------


{
    inputs,
    outputs,
    lib,
    config,
    pkgs,
    nix-colors,
    ...
}: 
{
    imports = [
        inputs.hardware.nixosModules.framework-13-7040-amd
        ./hardware-configuration.nix

        # Enable home-manager as a NixOS module
        inputs.home-manager.nixosModules.home-manager

        inputs.sops-nix.nixosModules.sops


        # Users
        ../../users/niko

        # Features
        ../../features/groups/wayland_desktop
        ../../features/groups/cli
        # ../../features/github
        ../../features/firefox
        ../../features/fonts
        ../../features/bitwarden
        ../../features/dolphin
        # ../../features/freecad
        ../../features/gimp
        ../../features/grimblast
        ../../features/gwenview
        ../../features/imv
        ../../features/inkscape
        #../../features/kitty
        ../../features/krita
        ../../features/obsidian
        ../../features/orca-slicer
        ../../features/prusa-slicer
        ../../features/prismlauncher
        ../../features/rofi
        ../../features/steam

    ];

    nixpkgs = {
        overlays = [
            # Add overlays your own flake exports (from overlays and pkgs dir):
            outputs.overlays.additions
            outputs.overlays.modifications
            outputs.overlays.unstable-packages

            # You can also add overlays exported from other flakes:
            # neovim-nightly-overlay.overlays.default
        ];
        config = {
            allowUnfree = true;
            permittedInsecurePackages = [
                "electron-39.8.10"
            ];
        };
    };

    nix = let
        flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in {
        settings = {
            # Enable flakes and new 'nix' command
            experimental-features = "nix-command flakes";
        };

        channel.enable = false;
  };

#----------------------------------------------------------------
# 2. Host Configuration
#----------------------------------------------------------------

# 2.1 Sops
    sops = {
        defaultSopsFile = ./secrets.yaml;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        secrets.laptop_secret = {};
    };
    
# 2.2 Networking
    networking = {
        networkmanager = {
            enable = true;
            wifi.powersave = false;
        };

        hostName = "laptop-fw13";

        firewall.allowedTCPPorts = [ 44444 43939 2302 ];
    };

# 2.3 System Packages
    environment.systemPackages = with pkgs; [
    ];

# 2.4 Services

    # Enable CUPS to print documents.
    services.printing = {
        enable = true;
        drivers = [ pkgs.brlaser ];
    };

    # Gnome Keyring   
    services.gnome.gnome-keyring.enable = true;

    services.getty = {
        autologinUser = "niko";
        autologinOnce = true;
    };

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };
    # Ly Display Manager
    #services.displayManager.ly = {
    #  enable = false;
    #  x11Support = false;
    #};

    # services.xserver.xkbOptions = "caps:swapescape";

    services.keyd = {
        enable = true;

        keyboards = {
            default = {
                ids = [ "*" ];  # apply to all keyboards

                settings = {
                    main = {
                        capslock = "esc";
                        esc = "capslock";
                    };
                };
            };
        };
    };

    systemd.services.keyd.serviceConfig.NoNewPrivileges = lib.mkForce false;
    systemd.services.keyd.serviceConfig.CapabilityBoundingSet = lib.mkForce [
       "CAP_SETGID"
       "CAP_SETUID"
       "CAP_SYS_ADMIN"
       "CAP_SYS_NICE"
       "CAP_IPC_LOCK"
    ];

    # For Mullvad vpn
    services.resolved.enable = true;
    services.mullvad-vpn.enable = true;

    # IOS Specifics
    services.usbmuxd = {
        enable = true;
        package = pkgs.usbmuxd2;
    };


# 2.5 Misc

    # Set your time zone.
    time.timeZone = "Europe/Paris";

    # Select internationalisation properties.
    i18n = {
        defaultLocale = "en_US.UTF-8";

        extraLocaleSettings = {
            LC_ADDRESS = "fr_FR.UTF-8";
            LC_IDENTIFICATION = "fr_FR.UTF-8";
            LC_MEASUREMENT = "fr_FR.UTF-8";
            LC_MONETARY = "fr_FR.UTF-8";
            LC_NAME = "fr_FR.UTF-8";
            LC_NUMERIC = "fr_FR.UTF-8";
            LC_PAPER = "fr_FR.UTF-8";
            LC_TELEPHONE = "fr_FR.UTF-8";
            LC_TIME = "fr_FR.UTF-8";
        };
    };

    boot.extraModprobeConfig = ''
    options mt7921e disable_ps=1
    '';



    # Enable Polkit Agent
    security = {
        polkit.enable = true;
        pam.services.login.enableGnomeKeyring = true;
    };
  
    hardware = {
        # enables support for SANE scanners
        sane.enable = true; 

        bluetooth = {
            enable = true;
            powerOnBoot = true;
            settings = {
                General= {
                    Experimental = true;
                    FasConnectable = true;
                };
                Policy = {
                    AutoEnable = true;
                };
            };
        };
    };

    users.groups.keyd = {};

    # Do not change!
    system.stateVersion = "23.05";

#----------------------------------------------------------------
# 3. Home-manager Configuration
#----------------------------------------------------------------

    home-manager.useGlobalPkgs = true;

    home-manager.users.niko = {config, ...}: 
    let
        c = config.colorScheme.palette;
    in {

        imports = [ inputs.nix-colors.homeManagerModules.default inputs.nvf.homeManagerModules.nvf ];

        colorScheme = inputs.nix-colors.colorSchemes.solarized-light;

        programs.kitty = {
            enable = true;
            # themeFile = "Solarized_Light";
            settings = {
                font_family="JetBrains Mono Medium";
                # font_family="AcPlus ToshibaSat 8x16";
                font_size=14;
                window_margin_width=4;
                shell_integration=true;


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

        programs.chromium.enable = true;

        programs.gpg = {
            enable = true;
        };

        programs.gh = {
            enable = true;
        };

        services.gpg-agent = {
            enable = true;
            enableZshIntegration = true;
            pinentry.package = pkgs.pinentry-curses;
        };

        # Install Packages
        home.packages = with pkgs; [
            file
            appimage-run
            gcr # For Gnome keyRing
            unzip
            wl-clipboard
            wev
            brlaser
            ghostscript
            sops
            gamescope
            vintagestory
            openmw
            bluetuith
            cloudflared
            protonup-qt

            # IOS
            libimobiledevice
            ifuse
        ];

        services.hyprpaper = {
            enable = true;
            settings = {
                ipc = "on";
                splash = false;
                preload = [
                    "~/Pictures/Artworks/My_Paintings/A_cloudy_day_at_sea.jpeg"
                ];
                wallpaper = [
                    {
                    monitor = "";
                    path = "~/Pictures/Artworks/My_Paintings/A_cloudy_day_at_sea.jpeg";
                    fit_mode = "fill";
                    }
                ];
            };
        };
  
        # Swap caps_lock and escape "caps:swapescape"
        home.keyboard = {
            layout = "us";
            variant = "altgr-intl";
            options = [ "compose:ralt" ]; 
        };

        services.playerctld = {
            enable = true;
        };

        programs.nvf = {
            enable = true;
            enableManpages = true;
            defaultEditor = true;

            settings.vim = {
                ui.noice = {
                    enable = true;
                    setupOpts = {
                    };
                };
                notify.nvim-notify = {
                    enable = true;
                };
                lineNumberMode = "relNumber";
                options = {
                    cursorline = true;
                    colorcolumn = "80";
                    tabstop = 4;
                    shiftwidth = 4;
                    softtabstop = 4;
                };
                globals = {
                    mapleader = " ";
                    maplocalleader = ",";
                };

                extraPlugins = {
                    vim-tmux-navigator = {
                        package = pkgs.vimPlugins.vim-tmux-navigator;

                        # plugin-local setup
                        setup = ''
                            vim.g.tmux_navigator_no_mappings = 1
                        '';
                    };
                    #vim-tpipeline = {
                    #    package = pkgs.vimPlugins.vim-tpipeline;

                    #        setup = ''
                    #        vim.g.tpipeline_autoembed = 0
                    #        '';
                    #        #vim.g.tpipeline_clearstl = 1
                    #};
                };

                luaConfigRC = {
                    tmuxNavigatorKeymaps = ''
                        local map = vim.keymap.set

                        map('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>')
                        map('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>')
                        map('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>')
                        map('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>')
                    '';
                };

                statusline.lualine.enable = true;
                treesitter.enable = true;
                lsp.enable = true;
                languages = {
                    enableTreesitter = true;
                    clang.enable = true;
                    cmake.enable = true;
                    nix.enable = true;
                    css.enable = true;
                    html.enable = true;
                };
                theme = {
                    enable = true;
                    name = "base16";
                    transparent = true;

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
                        desc = "Indent right";
                    }
                    {
                        mode = "n";
                        key = "<S-Tab>";
                        action = "<<";
                        desc = "Indent left";
                    }
                    {
                        mode = "v";
                        key = "<Tab>";
                        action = ">gv";
                        desc = "Indent right";
                    }
                    {
                        mode = "v";
                        key = "<S-Tab>";
                        action = "<gv";
                        desc = "Indent left";
                    }
                    {
                        mode = "n";
                        key = "<C-h>";
                        action = "<C-w>h";
                    }
                    {
                        mode = "n";
                        key = "<C-l>";
                        action = "<C-w>l";
                    }
                    {
                        mode = "n";
                        key = "<C-j>";
                        action = "<C-w>j";
                    }
                    {
                        mode = "n";
                        key = "<C-k>";
                        action = "<C-w>k";
                    }
                    {
                        mode = "v";
                        key = "<leader>/";
                        action = "gc";
                    }
                    {
                        mode = "n";
                        key = "gd";
                        lua = true;
                        action = ''
                        function()
                        vim.lsp.buf.definition()
                        end
                        '';
                        desc = "Go to definition";
                    }
                    {
                        mode = "n";
                        key = "<leader>]";
                        lua = true;
                        action = ''
                            function()
                            vim.cmd("normal! \\<C-i>")
                            end
                        '';
                        desc = "Jump forward";
                    }
                    {
                        mode = "n";
                        key = "<leader>[";
                        action = "<C-o>";
                        desc = "Jump back";
                    }
                    {
                        mode = "n";
                        key = "<leader>n";
                        action = "<cmd>tabnext<CR>";
                        desc = "Go to next tab";
                    }
                    {
                        mode = "n";
                        key = "<leader>p";
                        action = "<cmd>tabprevious<CR>";
                        desc = "Go to previous tab";
                    }
                    {
                        mode = "n";
                        key = "<leader>m";
                        action = "<cmd>tab split<CR>";
                        desc = "Open the current window in a new tab (maximize)";
                    }
                    {
                        mode = "n";
                        key = "<leader>M";
                        action = "<cmd>tab close<CR>";
                        desc = "Close current tab";
                    }
                ];
            };
        };

        # Nicely reload system units when changing configs
        systemd.user.startServices = "sd-switch";

        # Do not change!
        home.stateVersion = "25.05";
    };

}

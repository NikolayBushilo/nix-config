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
    # Hardware stuff
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
    ../../features/freecad
    ../../features/gimp
    ../../features/grimblast
    ../../features/gwenview
    ../../features/imv
    ../../features/inkscape
    ../../features/kitty
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

  # Sops
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.laptop_secret = {};


  # Device hostname
  networking.hostName = "laptop-fw13";
  
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 42420 ];

  # Enable networking
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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


  # Ly Display Manager
  #services.displayManager.ly = {
  #  enable = false;
  #  x11Support = false;
  #};

  boot.extraModprobeConfig = ''
  options mt7921e disable_ps=1
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # enables support for SANE scanners
  hardware.sane.enable = true; 

  # Enable Polkit Agent
  security.polkit.enable = true;
  
  # Gnome Keyring   
  services.gnome.gnome-keyring.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;

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

  hardware.bluetooth = {
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


  # Install Packages
  environment.systemPackages = with pkgs; [
  ];

    services.xserver.xkbOptions = "caps:swapescape";

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

        colorScheme = inputs.nix-colors.colorSchemes.windows-95;

        programs.kitty = {
            enable = true;
            # themeFile = "Solarized_Light";
            settings = {
                font_family="JetBrains Mono Medium";
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
   ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        "~/Pictures/SKALD-MapAndWallpaper/Wallpaper/Skald_Keyart_v2_Pixelated_4K.png"
      ];
      wallpaper = [
        # "eDP-1,~/Pictures/SKALD-MapAndWallpaper/Wallpaper/Skald_Keyart_v2_Pixelated_4K.png"
        {
            monitor = "";
            path = "~/Pictures/SKALD-MapAndWallpaper/Wallpaper/Skald_Keyart_v2_Pixelated_4K.png";
            fit_mode = "fill";
        }
      ];
    };
  };
  
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Swap caps_lock and escape
  home.keyboard = {
    layout = "us";
    variant = "altgr-intl";
    options = [ "compose:ralt" "caps:swapescape" ];
  };

  services.playerctld = {
    enable = true;
  };

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

  # Do not change!
  home.stateVersion = "25.05";
 };

}

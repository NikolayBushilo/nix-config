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

  # Do not change!
  system.stateVersion = "23.05";


#----------------------------------------------------------------
# 3. Home-manager Configuration
#----------------------------------------------------------------

 home-manager.useGlobalPkgs = true;

 home-manager.users.niko = {

    programs.kitty = {
        enable = true;
        settings = {
            font_family="JetBrains Mono Medium";
            font_size=15;
            window_margin_width=4;
            shell_integration=false;
            themeFile = "gruvbox-dark";
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
     hyprpaper
     brlaser
     ghostscript
     sops
   ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [
        "/home/niko/Pictures/solarized_light_wallpaper.jpg"
      ];
      wallpaper = [
        "DP-2,/home/niko/Pictures/solarized_light_wallpaper.jpg"
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

  # Do not change!
  home.stateVersion = "25.05";
 };

}

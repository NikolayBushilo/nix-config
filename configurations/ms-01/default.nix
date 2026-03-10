#----------------------------------------------------------------
#    __  _______    ___ ___
#   /  |/  / __/___/ _ <  /
#  / /|_/ /\ \/___/ // / / 
# /_/  /_/___/    \___/_/  
#                             
#----------------------------------------------------------------
#  License : MIT
#  Author  : Nikolay Bushilo 
#  URL     : COMING SOON 
#  Info    : NixOS server and hypervisor.
#----------------------------------------------------------------
#  Index:
#   1. Flake Stuff..............................................
#   2. Host Configuration.......................................
#     2.1 Sops..................................................
#     2.2 MicroVM...............................................
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
  self,
  ...
}: {
  imports = [
    # This is on pause until I find the common hardware modules
    # inputs.hardware.nixosModules.framework-13-7040-amd
    ./hardware-configuration.nix

    # Enable home-manager as a NixOS module
    inputs.home-manager.nixosModules.home-manager

    inputs.sops-nix.nixosModules.sops

    # MicroVM Host to manage vms
    inputs.microvm.nixosModules.host

    # Import User
    ../../users/niko

    # Features
    ../../features/motd.nix
    ../../features/groups/cli
    ../../features/minecraft
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
      trusted-users = [ "root" "niko" ];
    };

    channel.enable = false;
  };

#----------------------------------------------------------------
# 2. Host Configuration
#----------------------------------------------------------------
  
# 2.1 Sops
    sops.defaultSopsFile = ./secrets.yaml;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

# 2.2 MicroVM
    microvm = {
        host.enable = true;

        autostart = [
            vm-edge
        ];

        # Declare VMs
        vms.vm-edge = {
            flake = self;
            updateFlake = "git+https://github.com/NikolayBushilo/nix-config";
        };
    };


# 2.3 Networking
    networking = {
        networkmanager.enable = false;
        useNetworkd = true;

        hostName = "ms-01";
    };
 
    systemd.network = {

        enable = true;

        # Create Network Bridges
        netdevs = {
            "br-core" = {
                netdevConfig = {
                    Name = "br-core";
                    Kind = "bridge";
                };
            };
            "br-edge" = {
                netdevConfig = {
                    Name = "br-edge";
                    Kind = "bridge";
                };
            };
        };
        networks = {
            # Attach NICs to bridges
            "10-core-members" = {
                matchConfig.Name = "enp88s0";
                networkConfig.Bridge = "br-core";
            };

            "10-edge-members" = {
                matchConfig.Name = "enp1s0";
                networkConfig.Bridge = "br-edge";
            };

            # Configure bridges
            "20-core-config" = {
                matchConfig.Name = "br-core";
                networkConfig = {
                    DHCP = "ipv4";
                };
            };

            "20-edge-config" = {
                matchConfig.Name = "br-edge";
                networkConfig = {
                    LinkLocalAddressing = "no";
                    ConfigureWithoutCarrier = true;
                };
            };

            # Attach exposed TAP interface named "vm-edge"
            "30-vm-edge-bridge" = {
                matchConfig.Name = "vm-edge";
                networkConfig.Bridge = "br-edge";
            };
        };
    };


# 2.4 System Packages
    environment.systemPackages = with pkgs; [
        git
        kitty.terminfo
        dig
    ];

# 2.5 Services

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;

# 2.6 Misc

    # Set time zone
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


    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use latest kernel.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
        extraConfig = ''
            Defaults:niko !requiretty
        '';
    };



    # Do not change!
    system.stateVersion = "25.11";


#----------------------------------------------------------------
# 3. Home-manager Configuration
#----------------------------------------------------------------

 home-manager.users.niko = {
   programs.home-manager.enable = true;
   home.packages = with pkgs; [
   ];

   # Do not change!
   home.stateVersion = "25.05";
 };

}

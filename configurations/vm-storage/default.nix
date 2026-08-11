#----------------------------------------------------------------
#    ______                           _   ____  ___
#   / __/ /____  _______ ____ ____   | | / /  |/  /
#  _\ \/ __/ _ \/ __/ _ `/ _ `/ -_)  | |/ / /|_/ / 
# /___/\__/\___/_/  \_,_/\_, /\__/   |___/_/  /_/  
#                       /___/
# 
#----------------------------------------------------------------
#  License : MIT
#  Author  : Nikolay Bushilo 
#  URL     : COMING SOON 
#  Info    : Configuration for a virtual machine.
#----------------------------------------------------------------
#  Index:
#   1. Flake Stuff..............................................
#   2. Virtual Machine Configuration............................
#     2.1 Boot..................................................
#     2.2 File Systems..........................................
#     2.3 Sops..................................................
#     2.5 Networking............................................
#     2.6 System Packages.......................................
#     2.7 Services..............................................
#     2.8 NixOS Containers......................................
#     2.9 Users.................................................
#     2.10 Misc..................................................
#----------------------------------------------------------------

#----------------------------------------------------------------
# 1. Flake Stuff
#----------------------------------------------------------------

{
    lib,
    inputs,
    outputs,
    config,
    pkgs,
    self,
    ...
}: let 
    ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

    managementInterface = "storage-mgmt";
    defaultInterface = "storage-default";

    managementAddress = "10.1.0.75/24";
    managementGateway = "10.1.0.254";

    dnsServer = "10.1.70.11";
in {
    imports = [
        

        # Enable home-manager as a NixOS module
        #inputs.home-manager.nixosModules.home-manager

        # Sops-nix for secret decription
        inputs.sops-nix.nixosModules.sops

        # Import Disko + Disk configuration
        inputs.disko.nixosModules.disko
        ./disk-configuration.nix

        # Features
        ../../features/qemu-guest
        #../../features/zsh
        #../../features/bat
        #../../features/eza
        #../../features/fzf
        #../../features/git
        #../../features/lf
        #../../features/nvf
        #../../features/ripgrep
        #../../features/zoxide
        #../../features/btop
        #../../features/minecraft
        #../../features/cloudflared
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
# 2. Virtual Machine Configuration
#----------------------------------------------------------------

# 2.1 Boot
    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
        supportedFilesystems = [ "zfs" ];
        zfs = {
            extraPools = [ "rpool" ];
            forceImportRoot = false;
        };
    };

# 2.2 File Systems
    fileSystems."/data/identity" = {
        device = "vm-storage-identity";
        fsType = "virtiofs";
        neededForBoot = true;
    };

    fileSystems."/etc/machine-id" = {
        device = "/data/identity/machine-id";
        fsType = "none";
        options = [ "bind" ];
        depends = [ "/data/identity" ];
    };

# 2.3 Sops
    sops = {
        defaultSopsFile = ./secrets.yaml;

        age.sshKeyPaths = [ "/data/identity/ssh_host_ed25519_key" ];

        secrets = {
            example-key = {};
        };
    };

# 2.5 Networking
    networking = {
        hostId = "51d57c81";
        hostName = "vm-storage";
        useNetworkd = true;
        firewall = {
            enable = true;
            interfaces = {
                ${managementInterface}.allowedTCPPorts = [ 22 ]; 

                br-default = {
                    allowedTCPPorts = [];
                    allowedUDPPorts = [];
                };
            };

        };
    };

    systemd.network = {
        enable = true;

        links = {
            "10-management" = {
                matchConfig.MACAddress = "BC:24:11:CB:74:64";
                linkConfig.Name = managementInterface;
            };

            "20-default" = {
                matchConfig.MACAddress = "BC:24:11:CD:1F:EB";
                linkConfig.Name = defaultInterface;
            };

        };

        netdevs = {
            "20-br-default" = {
                netdevConfig = {
                    Kind = "bridge";
                    Name = "br-default";
                };

                bridgeConfig = {
                    STP = false;
                    ForwardDelaySec = 0;
                };
            };

        };

        networks = {
            "10-management" = {
                    matchConfig.Name = managementInterface;
                    address = [ managementAddress ];
                    routes = [ 
                        { 
                            Gateway = managementGateway;
                        }   
                    ];
                    networkConfig = {
                        DHCP = "no";
                        IPv6AcceptRA = false;
                    };

                    linkConfig.RequiredForOnline = "routable";
                };

            "20-default-uplink" = {
                matchConfig.Name = defaultInterface;
                bridge = [ "br-default" ];

                networkConfig = {
                    DHCP = "no";
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = false;
                };

                linkConfig.RequiredForOnline = "enslaved";
            };

            "21-default-bridge" = {
                matchConfig.Name = "br-default";

                networkConfig = {
                    DHCP = "no";
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = false;
                    ConfigureWithoutCarrier = true;
                };

                linkConfig.RequiredForOnline = "carrier";
            };
        };
    };


# 2.6 System Packages
    environment.systemPackages = with pkgs; [
        git
        kitty.terminfo
        lf
    ];

# 2.7 Services
    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
            KbdInteractiveAuthentication = false;
        };

        hostKeys = [
            {
                path = "/data/identity/ssh_host_ed25519_key";
                type = "ed25519";
            }
        ];
    };

    systemd.services.systemd-machine-id-commit.enable = false;

# 2.8 Nixos Containers

    containers = {
    };

# 2.9 User
    users.mutableUsers = true;
    users.users.niko = {
        isNormalUser = true;
        initialPassword = "password";
        openssh.authorizedKeys.keyFiles = [
            ../../users/niko/id_ed25519_personal.pub
        ];
        extraGroups = ifTheyExist [
            "audio"
            "deluge"
            "docker"
            "git"
            "i2c"
            "libvirtd"
            "minecraft"
            "mysql"
            "networkmanager"
            "plugdev"
            "podman"
            "tss"
            "video"
            "wheel"
            "lp"
            "scanner"
            "dialout"
            "wireshark"
        ];
    };

# 2.10 Misc

    security.sudo = {
        enable = true;
        wheelNeedsPassword = false;
    };

    # Do not change!
    system.stateVersion = "25.11";

    # Home-manager Configuration
    # --------------------------
    #home-manager.users.niko = {
    #    programs.home-manager.enable = true;
    #    home.packages = with pkgs; [
    #    ];

    #    # Do not change!
    #    home.stateVersion = "25.05";
    #};
}

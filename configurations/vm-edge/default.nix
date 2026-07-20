#----------------------------------------------------------------
#    ____   __           _   ____  ___
#   / __/__/ /__ ____   | | / /  |/  /
#  / _// _  / _ `/ -_)  | |/ / /|_/ / 
# /___/\_,_/\_, /\__/   |___/_/  /_/  
#          /___/
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
#     2.4 Proxmox...............................................
#     2.5 Networking............................................
#     2.6 System Packages.......................................
#     2.7 Services..............................................
#     2.8 Misc..................................................
#     2.9 Users.................................................
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
            # forceImportRoot = false;
            # devNodes = "/dev/disk/by-path";
            # requestEncryptionCredentials = false;
        };
        # initrd.kernelModules = [ "zfs" ];
        # kernelModules = [ "zfs" ];
        # initrd.availableKernelModules = [
        #     "ahci"
        #     "ata_piix"
        #     "sd_mod"
        #     "sr_mod"
        #     "virtio_pci"
        #     "virtio_blk"
        #     "virtio_scsi"
        # ];
    };

# 2.2 File Systems
    # fileSystems."/" = {
    #     device = "rpool/root";
    #     fsType = "zfs";
    # };
    #
    # fileSystems."/nix" = {
    #     device = "rpool/nix";
    #     fsType = "zfs";
    # };
    #
    # fileSystems."/data" = {
    #     device = "rpool/persist";
    #     fsType = "zfs";
    # };
    #
# 2.3 Sops
    sops = {
        defaultSopsFile = ./secrets.yaml;

        age.sshKeyPaths = [ "/data/identities/ssh_host_ed25519_key" ];

        secrets.example-key = {};
        #secrets."cloudflared/minecraft_tunnel" = {
        #    owner = "cloudflared";
        #    group = "cloudflared";
        #    mode = "0400";
        #};

        #secrets.ssh_host_ed25519_key = {
        #    owner = "root";
        #    group = "root";
        #    mode = "0600";
        #};
    };

# 2.4 Proxmox

    # proxmox = {
    #     qemuConf = {
    #         cores = 4;
    #         memory = 16384;
    #         bios = "ovmf";
    #         name = "vm-core";
    #         agent = true;
    #     };
    #     qemuExtraConf = {
    #         cpu = "host";
    #         onboot = 1;
    #     };
    #     filenameSuffix = "vm-edge";
    # };

# 2.5 Networking
    networking.hostId = "2feb1f61";

    networking.useNetworkd = true;

    networking.firewall.enable = true;

    systemd.network.networks."10-eth" = {
        matchConfig.Type = "ether";
        networkConfig.DHCP = "ipv4";
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
        settings.PasswordAuthentication = false;

        hostKeys = [
            {
                path = "/data/identities/ssh_host_ed25519_key";
                type = "ed25519";
            }
            
        #    {
        #        path = config.sops.secrets.ssh_host_ed25519_key.path;
        #        type = "ed25519";
        #    }
        ];
    };

    #services.cloudflared = {
    #    enable = true;
    #    tunnels = {
    #        "a649e83a-4676-44cd-8672-f10c6a58299a" = {
    #            credentialsFile = "${config.sops.secrets."cloudflared/minecraft_tunnel".path}";
    #            default = "http_status:404";
    #            ingress = {
    #                "mc.bushilo.com" = {
    #                    service = "localhost:25565";
    #                };
    #            };
    #        };
    #    };
    #};

# 2.8 User
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

# 2.9 Misc

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

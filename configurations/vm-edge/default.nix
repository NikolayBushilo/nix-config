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
#     2.1 Bootloader............................................
#     2.2 Sops..................................................
#     2.3 Proxmox...............................................
#     2.4 Networking............................................
#     2.5 System Packages.......................................
#     2.6 Services..............................................
#     2.7 Misc..................................................
#     2.8 Users.................................................
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

        # Import Disk configuration
        ./disk-configuration.nix

        # Features
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

# 2.1 Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

# 2.1 Sops
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

# 2.2 Proxmox

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

# 2.3 Networking
    networking.useNetworkd = true;

    networking.firewall.enable = true;

    systemd.network.networks."10-eth" = {
        matchConfig.Type = "ether";
        networkConfig.DHCP = "ipv4";
    };



# 2.4 System Packages
    environment.systemPackages = with pkgs; [
        git
        kitty.terminfo
        lf
    ];

# 2.5 Services
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

    services.qemuGuest.enable = true;

# 2.6 User
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

# 2.7 Misc

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

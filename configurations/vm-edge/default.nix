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

    managementInterface = "edge-mgmt";
    ingressInterface = "edge-ingress";
    tunnelInterface = "edge-tunnel";

    managementAddress = "10.1.0.71/24";
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
        device = "vm-edge-identity";
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
            "cloudflared/tunnels/vm-edge/credentialFile" = {
                mode = "0400";
            };

            "cloudflared/certificateFile" = {
                mode = "0400";
            };
        };
    };

# 2.5 Networking
    networking = {
        hostId = "2feb1f61";
        hostName = "vm-edge";
        useNetworkd = true;
        firewall = {
            enable = true;
            interfaces = {
                ${managementInterface}.allowedTCPPorts = [ 22 ]; 

                br-ingress = {
                    allowedTCPPorts = [];
                    allowedUDPPorts = [];
                };

                br-tunnel = {
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
                matchConfig.MACAddress = "BC:24:11:4B:4F:44";
                linkConfig.Name = managementInterface;
            };

            "20-ingress" = {
                matchConfig.MACAddress = "BC:24:11:E6:0C:3F";
                linkConfig.Name = ingressInterface;
            };

            "30-tunnel" = {
                matchConfig.MACAddress = "BC:24:11:07:92:B2";
                linkConfig.Name = tunnelInterface;
            };
        };

        netdevs = {
            "20-br-ingress" = {
                netdevConfig = {
                    Kind = "bridge";
                    Name = "br-ingress";
                };

                bridgeConfig = {
                    STP = false;
                    ForwardDelaySec = 0;
                };
            };

            "30-br-tunnel" = {
                netdevConfig = {
                    Kind = "bridge";
                    Name = "br-tunnel";
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

            "20-ingress-uplink" = {
                matchConfig.Name = ingressInterface;
                bridge = [ "br-ingress" ];

                networkConfig = {
                    DHCP = "no";
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = false;
                };

                linkConfig.RequiredForOnline = "enslaved";
            };

            "21-ingress-bridge" = {
                matchConfig.Name = "br-ingress";

                networkConfig = {
                    DHCP = "no";
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = false;
                    ConfigureWithoutCarrier = true;
                };

                linkConfig.RequiredForOnline = "carrier";
            };

            "30-tunnel-uplink" = {
                matchConfig.Name = tunnelInterface;
                bridge = [ "br-tunnel" ];

                networkConfig = {
                    DHCP = "no";
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = false;
                };

                linkConfig.RequiredForOnline = "enslaved";
            };

            "31-tunnel-bridge" = {
                matchConfig.Name = "br-tunnel";

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
            
        #    {
        #        path = config.sops.secrets.ssh_host_ed25519_key.path;
        #        type = "ed25519";
        #    }
        ];
    };

    systemd.services.systemd-machine-id-commit.enable = false;

# 2.8 Nixos Containers

    containers = {
        cloudflared = {

            # Container config
            autoStart = true;
            privateNetwork = true;
            hostBridge = "br-tunnel";
            localAddress = "10.1.41.10/24";

            bindMounts = {
                "/run/secrets/cloudflared/certificateFile" = {
                    hostPath = config.sops.secrets."cloudflared/certificateFile".path;
                    isReadOnly = true;
                };

                "/run/secrets/cloudflared/tunnels/vm-edge/credentialFile" = {
                    hostPath = config.sops.secrets."cloudflared/tunnels/vm-edge/credentialFile".path;
                    isReadOnly = true;
                };
            };

            # Inside container
            config = { config, pkgs, lib, ... }:
            {
                imports = [
                ];

                networking = {
                    hostName = "cloudflared";
                    useDHCP = false;
                    useNetworkd = true;
                    useHostResolvConf = lib.mkForce false; # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
                    nameservers = [ dnsServer ]; 
                    defaultGateway = {
                        address = "10.1.41.254";
                        interface = "eth0";
                    };
                };

                services.cloudflared = {
                    enable = true;
                    certificateFile = "/run/secrets/cloudflared/certificateFile";
                    tunnels = {
                        "4cdf3fa5-1e08-44c9-8816-abdcb15b3aba" = {
                            credentialsFile = "/run/secrets/cloudflared/tunnels/vm-edge/credentialFile";
                            default = "http_status:404";
                            ingress = {
                                "*.bushilo.com" = {
                                    service = "https://10.1.40.11:443";

                                    originRequest = {
                                        originServerName = "test.bushilo.com";
                                        # httpHostHeader = "test.bushilo.com";
                                    };
                                };
                            };
                        };
                    };
                };


                systemd.network.enable = true;

                services.resolved.enable = false;

                system.stateVersion = "25.11";
            };
        };

        caddy = {
            autoStart = true;
            privateNetwork = true;

            hostBridge = "br-ingress";
            localAddress = "10.1.40.11/24";

            config = { lib, ... }:
            {
                networking = {
                    hostName = "caddy";

                    useDHCP = false;
                    useNetworkd = true;
                    useHostResolvConf = lib.mkForce false;

                    nameservers = [ dnsServer ];

                    defaultGateway = {
                        address = "10.1.40.254";
                        interface = "eth0";
                    };

                    firewall = {
                        enable = true;
                        allowedTCPPorts = [ 80 443 ];
                    };
                };

                systemd.network.enable = true;
                services.resolved.enable = false;

                services.caddy = {
                    enable = true;

                    globalConfig = ''
                        debug
                    '';

                    virtualHosts = {
                        "test.bushilo.com" = {
                            extraConfig = ''
                                header Content-Type "text/html; charset=utf-8"

                                respond <<HTML
                                <!doctype html>
                                <html lang="en">
                                <head>
                                <meta charset="utf-8">
                                <meta name="viewport" content="width=device-width, initial-scale=1">
                                <title>vm-edge ingress</title>
                                <style>
                                body {
                                margin: 0;
                                min-height: 100vh;
                                display: grid;
                                place-items: center;
                                background: #111827;
                                color: #e5e7eb;
                                font-family: system-ui, sans-serif;
                                }

                                main {
                                max-width: 42rem;
                                padding: 3rem;
                                border: 1px solid #374151;
                                border-radius: 1rem;
                                background: #1f2937;
                                }

                                h1 {
                                margin-top: 0;
                                color: #f9fafb;
                                }

                                code {
                                color: #93c5fd;
                                }
                                </style>
                                </head>

                                <body>
                                <main>
                                <h1>Cloudflare Tunnel → Caddy works</h1>
                                <p>
                                This response came from the Caddy NixOS container at
                                <code>10.1.40.11</code>.
                                </p>
                                </main>
                                </body>
                                </html>
                                HTML 200
                            '';
                        };
                        "foo.bushilo.com" = {
                            extraConfig = ''
                                header Content-Type "text/html; charset=utf-8"

                                respond <<HTML
                                <!doctype html>
                                <html lang="en">
                                <head>
                                <meta charset="utf-8">
                                <meta name="viewport" content="width=device-width, initial-scale=1">
                                <title>vm-edge ingress</title>
                                <style>
                                body {
                                margin: 0;
                                min-height: 100vh;
                                display: grid;
                                place-items: center;
                                background: #111827;
                                color: #e5e7eb;
                                font-family: system-ui, sans-serif;
                                }

                                main {
                                max-width: 42rem;
                                padding: 3rem;
                                border: 1px solid #374151;
                                border-radius: 1rem;
                                background: #1f2937;
                                }

                                h1 {
                                margin-top: 0;
                                color: #f9fafb;
                                }

                                code {
                                color: #93c5fd;
                                }
                                </style>
                                </head>

                                <body>
                                <main>
                                <h1>Cloudflare Tunnel → Caddy works</h1>
                                <p>
                                This response came from the Caddy NixOS container at
                                <code>10.1.40.11</code>.
                                (Foo)
                                </p>
                                </main>
                                </body>
                                </html>
                                HTML 200
                            '';
                        };
                    };
                };

                system.stateVersion = "25.11";
            };
        };
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

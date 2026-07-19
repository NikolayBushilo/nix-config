#----------------------------------------------------------------
#    _  ___        _____          ____     
#   / |/ (_)_ __  / ___/__  ___  / _(_)__ _
#  /    / /\ \ / / /__/ _ \/ _ \/ _/ / _ `/
# /_/|_/_//_\_\  \___/\___/_//_/_//_/\_, / 
#                                   /___/ (flake)
#                             
#----------------------------------------------------------------
#  License : MIT
#  Author  : Nikolay Bushilo 
#  URL     : COMING SOON 
#  Info    : A wizard's scroll.
#----------------------------------------------------------------
#  Index:
#   1. Flake Imports............................................
#     1.1. Custom packages......................................
#     1.2. Formatter............................................
#     1.3. Overlays.............................................
#     1.4. NixOS Modules........................................
#     1.5. Home-manager Modules.................................
#     1.6. Development Templates................................
#   2. NixOS configuration entrypoint w/ Home-manager module....
#     2.1. Framework 13 laptop..................................
#     2.2. MS-01 homelab server.................................
#     2.3. VM-edge Virtual Machine..............................
#   3. Standalone Home-manager configuration entrypoint.........
#     3.1. Universal standalone config..........................
#     3.2. Apple M2 standalone..................................
#----------------------------------------------------------------

#----------------------------------------------------------------
# 1. Flake Imports
#----------------------------------------------------------------
{
  description = "A wizard's scroll of computing";

  inputs = {

    # Nix Ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
        url = "github:mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
        url = "github:misterio77/nix-colors";
    };

    disko = {
        url = "github:nix-community/disko";
        inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nvf,
    sops-nix,
    nix-colors,
    disko,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {

# 1.1. custom packages
#=======================

    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

# 1.2. Formatter for my nix files
#==================================

    #available through 'nix fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

# 1.3. Overlays
#================

    # Custom packages and modifications
    overlays = import ./overlays {inherit inputs;};

# 1.4. NixOS modules
#=====================

    nixosModules = import ./modules/nixos;

# 1.5. Home-manager modules
#============================

    homeManagerModules = import ./modules/home-manager;

# 1.6. Development Templates
#=============================
    templates = {
        cpp = {
            path = ./templates/cpp;
            description = "C++ project with Nix, CMake, Clang and Ninja";
        };
    };

#----------------------------------------------------------------
# 2. Nixos configuration entrypoint w/ Home-manager as a module
#----------------------------------------------------------------

# Available through 'nixos-rebuild --flake .#{host}'

    nixosConfigurations = {
      # Framework 13 laptop
      "laptop-fw13" = nixpkgs.lib.nixosSystem {
        modules = [ ./configurations/laptop-fw13 ];
        specialArgs = {inherit inputs outputs self;};
      };

      # [DEPRICATED: REPLACED BY PROXMOX] MS-01 homelab server 
      "ms-01" = nixpkgs.lib.nixosSystem {
        modules = [ ./configurations/ms-01 ];
        specialArgs = {inherit inputs outputs self;};
      };

      # Virtual Machines
      "vm-edge" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configurations/vm-edge ];
        specialArgs = {inherit inputs outputs self;};
      };
    };

#----------------------------------------------------------------
# 3. Standalone Home-manager configuration entrypoint
#----------------------------------------------------------------

# Available through 'home-manager --flake .#standalone@{host}'

    homeConfigurations = {

      # Configuration I bring along on foreign devices
      "standalone@guest" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./features/standalone_guest.nix
        ];
      };

      # Configuration used on my M4 MacBook
      "standalone@macbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}

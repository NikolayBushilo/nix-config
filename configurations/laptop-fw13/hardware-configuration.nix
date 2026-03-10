{ config, lib, pkgs, modulesPath, ... }:

{

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  boot.initrd.luks.devices."luks-b3d21ef3-16eb-4f37-a278-94ed50270242".device = "/dev/disk/by-uuid/b3d21ef3-16eb-4f37-a278-94ed50270242";

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/bac084e9-1999-437a-bf09-89c346addc4d";
      fsType = "ext4";
    };
    
  boot.initrd.luks.devices."luks-f2cc99c1-fa32-49db-a8ef-e78feab23337".device = "/dev/disk/by-uuid/f2cc99c1-fa32-49db-a8ef-e78feab23337";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/BB1B-4556";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/b6345367-75ae-48f5-8d42-f2c411797c31"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp195s0f4u1c2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

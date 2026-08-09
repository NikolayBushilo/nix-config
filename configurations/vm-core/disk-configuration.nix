{ lib, ... }:

{
    disko.devices = {
        disk.main = {
            type = "disk";
            device = "/dev/sda";

            content = {
                type = "gpt";

                partitions = {
                    ESP = {
                        name = "ESP";
                        type = "EF00";
                        size = "512M";

                        content = {
                            type = "filesystem";
                            format = "vfat";
                            mountpoint = "/boot";
                            mountOptions = [ "umask=0077" ];
                        };
                    };

                    zfs = {
                        size = "100%";

                        content = {
                            type = "zfs";
                            pool = "rpool";
                        };
                    };
                };
            };
        };

        zpool.rpool = {
            type = "zpool";

            options = {
                ashift = "12";
            };

            rootFsOptions = {
                compression = "zstd";
            };

            datasets = {
                root = {
                    type = "zfs_fs";
                    options.canmount = "noauto";
                    mountpoint = "/";
                };

                nix = {
                    type = "zfs_fs";
                    options.canmount = "on";
                    mountpoint = "/nix";
                };
            };
        };
    };
}

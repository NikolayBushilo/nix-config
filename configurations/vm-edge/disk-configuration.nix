{ lib, ... }:

{
    disko.devices = {
        disk.main = {
            type = "disk";
            device = "/dev/sda";

            content = {
                type = "gpt";

                partitions = {
                    # MBR = {
                    #     type = "EF02"; 
                    #     size = "1M";
                    #     priority = 1; 
                    # };

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

                    # root = {
                    #     size = "100%";
                    #
                    #     content = {
                    #         type = "filesystem";
                    #         format = "ext4";
                    #         mountpoint = "/";
                    #     };
                    # };
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
                # mountpoint = "legacy";
            };

            datasets = {
                root = {
                    type = "zfs_fs";
                    options.canmount = "noauto";
                    # options.mountpoint = "legacy";
                    mountpoint = "/";
                };

                nix = {
                    type = "zfs_fs";
                    options.canmount = "on";
                    # options.mountpoint = "legacy";
                    mountpoint = "/nix";
                };

                persist = {
                    type = "zfs_fs";
                    options.canmount = "on";
                    # options.mountpoint = "legacy";
                    mountpoint = "/data";
                };
            };
        };
    };
}
# Example to create a bios compatible gpt partition
# { lib, ... }:
# {
#   disko.devices = {
#     disk.disk1 = {
#       device = lib.mkDefault "/dev/sda";
#       type = "disk";
#       content = {
#         type = "gpt";
#         partitions = {
#           boot = {
#             name = "boot";
#             size = "1M";
#             type = "EF02";
#           };
#           esp = {
#             name = "ESP";
#             size = "500M";
#             type = "EF00";
#             content = {
#               type = "filesystem";
#               format = "vfat";
#               mountpoint = "/boot";
#             };
#           };
#           root = {
#             name = "root";
#             size = "100%";
#             content = {
#               type = "lvm_pv";
#               vg = "pool";
#             };
#           };
#         };
#       };
#     };
#     lvm_vg = {
#       pool = {
#         type = "lvm_vg";
#         lvs = {
#           root = {
#             size = "100%FREE";
#             content = {
#               type = "filesystem";
#               format = "ext4";
#               mountpoint = "/";
#               mountOptions = [
#                 "defaults"
#               ];
#             };
#           };
#         };
#       };
#     };
#   };
# }

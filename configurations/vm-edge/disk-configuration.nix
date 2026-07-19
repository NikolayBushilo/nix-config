{ lib, ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/virtio-os";

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            priority = 1;
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
        atime = "off";
        xattr = "sa";
        acltype = "posixacl";
        normalization = "formD";
        mountpoint = "none";
      };

      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options = {
            canmount = "noauto";
          };
        };

        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };

        persist = {
          type = "zfs_fs";
          mountpoint = "/data";
        };
      };
    };
  };
}

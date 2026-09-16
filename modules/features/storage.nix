{ inputs, ... }:
{
  flake.modules.nixos.storage = { config, lib, ... }: {
    imports = [ inputs.disko.nixosModules.disko ];
    options.thestranger.diskDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/disk/by-id/REPLACE_WITH_INTERNAL_NVME_ID";
      description = "Stable by-id path of the internal 2 TiB disk. Disko erases this disk.";
    };
    config = {
      assertions = [
        {
          assertion = config.thestranger.diskDevice != "/dev/disk/by-id/REPLACE_WITH_INTERNAL_NVME_ID";
          message = "Set thestranger.diskDevice to the internal NVMe by-id path before installation.";
        }
      ];
      disko.devices.disk.internal = {
        type = "disk";
        device = config.thestranger.diskDevice;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                # Disko prompts for a passphrase. No key lives in the Nix store.
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-L"
                    "thestranger"
                  ];
                  subvolumes = builtins.listToAttrs (
                    map
                      ({ name, mountpoint }: {
                        inherit name;
                        value = {
                          inherit mountpoint;
                          mountOptions = [
                            "compress=zstd:1"
                            "noatime"
                          ];
                        };
                      })
                      [
                        {
                          name = "@root";
                          mountpoint = "/";
                        }
                        {
                          name = "@home";
                          mountpoint = "/home";
                        }
                        {
                          name = "@nix";
                          mountpoint = "/nix";
                        }
                        {
                          name = "@log";
                          mountpoint = "/var/log";
                        }
                        {
                          name = "@snapshots";
                          mountpoint = "/.snapshots";
                        }
                      ]
                  );
                };
              };
            };
          };
        };
      };
      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = [ "/" ];
      };
      # Zram is configured in base; no disk swap or hibernation by default.
      # The removable installer disk is deliberately absent from disko.devices.
    };
  };
}

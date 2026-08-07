# System disk: Samsung SSD 990 PRO with Heatsink 2TB
# Serial: S7DRNJ0Y104863E
# Stable by-id path prevents nvme0n1/nvme1n1 renumbering from targeting the wrong disk.
# Subvolumes: @ (root)  @home  @nix  @snapshots (/home/.snapshots)
# No swap partition — zRAM is used instead (see configuration.nix).
{ ... }: {
  disko.devices.disk.main = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_2TB_S7DRNJ0Y104863E";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          label = "nixos-boot";
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };
        root = {
          label = "nixos-root";
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              # Snapper stores /home snapshots here. Keeping this separate
              # prevents snapshots from recursively containing themselves.
              "@snapshots" = {
                mountpoint = "/home/.snapshots";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}

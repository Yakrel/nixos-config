# Disk layout: nvme0n1 (Samsung 990 PRO 2TB NVMe SSD) — 1G EFI boot + btrfs root
# Subvolumes: @ (root)  @home  @nix (disk accounting + noatime isolation)  @snapshots (/home/.snapshots)
# No swap — zRAM is used instead (see configuration.nix)
{ ... }: {
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type   = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1G";
          type = "EF00";
          content = {
            type        = "filesystem";
            format      = "vfat";
            mountpoint  = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type      = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "@" = {
                mountpoint   = "/";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@home" = {
                mountpoint   = "/home";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@nix" = {
                mountpoint   = "/nix";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              # Where snapper stores /home snapshots.
              # Must be a separate subvol — otherwise snapshots nest inside each other.
              "@snapshots" = {
                mountpoint   = "/home/.snapshots";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}

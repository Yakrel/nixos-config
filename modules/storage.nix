{ ... }:

{
  # Existing data disks. These are mounted by filesystem UUID and are never
  # formatted by disko, so device-name changes (sda/nvme1n1) are harmless.
  fileSystems."/data/NVMe_1TB" = {
    device = "/dev/disk/by-uuid/d28ebb9a-91e7-42e9-b68c-ce7725a7bfd9";
    fsType = "btrfs";
    options = [
      "nofail"
      "noatime"
      "compress=zstd"
      "x-systemd.device-timeout=5s"
      "x-gvfs-show"
      "x-gvfs-name=NVMe_1TB"
    ];
  };

  fileSystems."/data/SATA_480G" = {
    device = "/dev/disk/by-uuid/a2ec5392-7770-4f1c-8f1f-ba7ceb9059a3";
    fsType = "btrfs";
    options = [
      "nofail"
      "noatime"
      "compress=zstd"
      "x-systemd.device-timeout=5s"
      "x-gvfs-show"
      "x-gvfs-name=SATA_480G"
    ];
  };
}

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Boot & Kernel modules for Intel i5-13400F & NVMe/SATA storage
  boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Graphics / Hardware Acceleration (Mesa, RADV, VA-API for AMD GPU)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # CPU Microcode & Full Firmware
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Exposes battery percentage to Plasma
        FastConnectable = true;
      };
    };
  };

  # Switch USB Wi-Fi/Bluetooth dongles out of storage mode
  hardware.usb-modeswitch.enable = true;

  # SSD TRIM support
  services.fstrim.enable = true;

  # Automatic USB/Disk mounting support in Dolphin
  services.udisks2.enable = true;
  services.gvfs.enable = true;
}

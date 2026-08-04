{ config, pkgs, ... }:

{
  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Switch USB Wi-Fi/Bluetooth dongles out of storage mode
  hardware.usb-modeswitch.enable = true;

  # SSD TRIM support
  services.fstrim.enable = true;
}

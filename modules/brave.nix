{ pkgs, ... }:

{
  # NixOS' Chromium policy module explicitly writes policy for Brave as well.
  # Bitwarden is installed automatically but remains user-disableable.
  programs.chromium = {
    enable = true;
    extraOpts.ExtensionSettings = {
      # Bitwarden
      "nngceckbapebfimnlniiiahkandclblb" = {
        installation_mode = "normal_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
        toolbar_pin = "default_pinned";
      };
      # Free Download Manager
      "ahmpjcflkgiildlgicmflglnfdmpaldp" = {
        installation_mode = "normal_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
        toolbar_pin = "default_pinned";
      };
    };
  };
  environment.systemPackages = [ pkgs.brave ];
}

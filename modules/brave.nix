{ pkgs, jdownloaderInterceptor, ... }:

let
  # The extension source is a locked flake input. Its own manifest carries the
  # stable public key, so Brave can load the immutable source tree directly
  # without copying or patching files at build/runtime.
  braveWithJDownloader = pkgs.brave-origin.override {
    commandLineArgs = "--load-extension=${jdownloaderInterceptor}";
  };
in
{
  # NixOS' Chromium policy module explicitly writes policy for Brave as well.
  # Bitwarden is installed automatically but remains user-disableable.
  programs.chromium = {
    enable = true;
    extraOpts.ExtensionSettings = {
      "nngceckbapebfimnlniiiahkandclblb" = {
        installation_mode = "normal_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
        toolbar_pin = "default_pinned";
      };
    };
  };

  environment.systemPackages = [ braveWithJDownloader ];
}

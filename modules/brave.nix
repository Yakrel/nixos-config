{ pkgs, ... }:

{
  # NixOS' Chromium policy module explicitly writes policy for Brave as well.
  # Bitwarden is installed automatically but remains user-disableable.
  programs.chromium = {
    enable = true;
    extraOpts = {
      # Default Search Engine (Google)
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}";
      DefaultSearchProviderSuggestURL = "https://www.google.com/complete/search?output=chrome&q={searchTerms}";
      DefaultSearchProviderName = "Google";
      DefaultSearchProviderIconURL = "https://www.google.com/favicon.ico";


      ExtensionSettings = {
        # Bitwarden
        "nngceckbapebfimnlniiiahkandclblb" = {
          installation_mode = "normal_installed";
          update_url = "https://clients2.google.com/service/update2/crx";
          toolbar_pin = "default_pinned";
        };
        # Aria2 Explorer (Download Manager)
        "mpkodccbngfoacfalldjimigbofkhgjn" = {
          installation_mode = "normal_installed";
          update_url = "https://clients2.google.com/service/update2/crx";
          toolbar_pin = "default_pinned";
        };
      };
    };
  };

  environment.systemPackages = [ pkgs.brave-origin ];
}

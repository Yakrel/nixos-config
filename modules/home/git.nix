{ ... }: {
  programs.git = {
    enable = true;
    # Git is installed system-wide for normal workstation use. The fresh
    # installer uses the Git already available on the NixOS live ISO;
    # Home Manager owns only the per-user Git configuration.
    package = null;
    settings.user = {
      name = "Berkay Yetgin";
      email = "85676216+Yakrel@users.noreply.github.com";
    };
  };
}

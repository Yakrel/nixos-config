{ ... }: {
  programs.git = {
    enable = true;
    # Git itself is installed system-wide so install.sh can use it inside the
    # freshly installed target system. Home Manager only owns user config.
    package = null;
    settings.user = {
      name = "Berkay Yetgin";
      email = "85676216+Yakrel@users.noreply.github.com";
    };
  };
}

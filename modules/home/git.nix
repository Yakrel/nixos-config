{ ... }: {
  programs = {
    git = {
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

    gh = {
      enable = true;
      settings.git_protocol = "https";
      # Keep Git authentication declarative: after the one-time `gh auth login`,
      # normal git fetch/pull/push uses the GitHub CLI credential helper instead
      # of KDE askpass or a separate SSH key.
      gitCredentialHelper.enable = true;
    };
  };
}

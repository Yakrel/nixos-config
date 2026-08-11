{ pkgs, ... }:

let
  # The upstream package also exposes the Zero Trust taskbar application.
  # Keep only the consumer-facing CLI and its required daemon.
  cloudflareWarpCli = pkgs.cloudflare-warp.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      rm -f \
        $out/bin/warp-taskbar \
        $out/share/applications/com.cloudflare.WarpTaskbar.desktop \
        $out/share/systemd/user/warp-taskbar.service
      rm -rf $out/share/warp
    '';
  });
in

{
  services.cloudflare-warp = {
    enable = true;
    package = cloudflareWarpCli;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}

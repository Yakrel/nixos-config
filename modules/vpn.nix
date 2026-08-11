{ ... }:

{
  services.cloudflare-warp.enable = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}

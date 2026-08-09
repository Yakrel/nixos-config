{ pkgs, jdownloaderInterceptor, ... }:

let
  # Chrome derives an unpacked extension ID from its path unless the manifest
  # contains a public key. Nix store paths change when the source changes, so
  # inject a fixed public key at build time to keep the extension ID stable
  # across nixupdate revisions. This key is public metadata, not a secret.
  jdownloaderExtensionKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvGAFBT98l0709sE3Rq8dRY3eR4XgosKgC54YOAfHHXpio5p19tAvVSa5TdJPheDv4DtoYGFaVI17eZRdmrSFp1NnLZWfTcI8tVjQVASt44Fyt74lURf03eLyBnbtN0TVOzXHQZJaXAftOuB0X0sRy+G78aAIrpcaAVJy3YES+6fOoXSvFTVZUW91H/2fMwcILW4lj/3g3WL/PO4Lfr2bAToOLhsC5E57QZDhZK42QwoaEuVHhBQkH1JY3Kl9x/r0/BSVJLLgn3plj+DHna9yXFTJ9a9WqXRVXSFN+R1E+Fw7c8/YMsYxTVrihbldx6Xb4vp8Hg0hQ+buc0SbwOqpuQIDAQAB";

  upstreamManifest = builtins.fromJSON (builtins.readFile "${jdownloaderInterceptor}/manifest.json");
  stableManifest = pkgs.writeText "jdownloader-download-interceptor-manifest.json" (
    builtins.toJSON (upstreamManifest // { key = jdownloaderExtensionKey; })
  );

  # Build an immutable extension tree in the Nix store. This is a package build,
  # not a runtime mutation of ~/.config or the Brave profile.
  jdownloaderExtension = pkgs.runCommand "jdownloader-download-interceptor" { } ''
    mkdir -p "$out"
    cp -R ${jdownloaderInterceptor}/. "$out/"
    rm -f "$out/manifest.json"
    ln -s ${stableManifest} "$out/manifest.json"
  '';

  braveWithJDownloader = pkgs.brave-origin.override {
    commandLineArgs = "--load-extension=${jdownloaderExtension}";
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

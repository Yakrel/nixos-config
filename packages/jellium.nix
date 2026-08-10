{ pkgs }:

let
  archive = pkgs.fetchzip {
    url = "https://nightly.link/andrewrabert/jellium-desktop/actions/runs/30776111020/linux-appimage-x86_64.zip";
    hash = "sha256-WDaofSbKC+zbIyj1EtSOx6JFq2HGhvz44JtuVvJFW4Y=";
    stripRoot = false;
  };

  src = "${archive}/JelliumDesktop-0.1.0-dev+0b88f9d-x86_64.AppImage";
in
pkgs.appimageTools.wrapType2 rec {
  pname = "jellium-desktop";
  version = "0.1.0-dev-0b88f9d";

  inherit src;

  extraInstallCommands =
    let
      contents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };
    in
    ''
      install -Dm644 \
        ${contents}/net.nullsum.JelliumDesktop.desktop \
        $out/share/applications/net.nullsum.JelliumDesktop.desktop

      install -Dm644 \
        ${contents}/net.nullsum.JelliumDesktop.svg \
        $out/share/icons/hicolor/scalable/apps/net.nullsum.JelliumDesktop.svg
    '';

  meta = {
    description = "Unofficial Jellyfin desktop client built with CEF and mpv";
    homepage = "https://github.com/andrewrabert/jellium-desktop";
    license = pkgs.lib.licenses.gpl2Only;
    mainProgram = "jellium-desktop";
    platforms = [ "x86_64-linux" ];
  };
}

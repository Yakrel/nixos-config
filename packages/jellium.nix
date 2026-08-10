{ pkgs, jelliumNightly }:

let
  appImage = pkgs.runCommand "jellium-desktop-nightly.AppImage" { } ''
    cp ${jelliumNightly}/JelliumDesktop-*-x86_64.AppImage "$out"
  '';
in
pkgs.appimageTools.wrapType2 rec {
  pname = "jellium-desktop";
  version = "nightly";
  src = appImage;

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

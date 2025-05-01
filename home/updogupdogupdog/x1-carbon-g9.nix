{ config, pkgs, lib, ... }:

{
  imports = [
    ./services/cam-status.nix
  ];

  home.packages = with pkgs; [
    discord
    plex-desktop
    spotify
    toggle-cam
  ];

  home.activation.removeDownloadsDir = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    if [ -d "$HOME/Downloads" ] && [ ! -L "$HOME/Downloads" ]; then
      echo "Removing preexisting ~/Downloads directory..."
      rm -rf "$HOME/Downloads"
    fi
  '';

  home.file = {
    "Downloads" = {
      source = config.lib.file.mkOutOfStoreSymlink "/data/Downloads";
      force = true;
    };
  };

  home.activation.plexDesktopFix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.local/share/applications
    cp ${pkgs.plex-desktop}/share/applications/plex-desktop.desktop ~/.local/share/applications/plex-desktop.desktop
    sed -i 's|^Exec=.*|Exec=plex-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland|' ~/.local/share/applications/plex-desktop.desktop
    sed -i 's|^Categories=.*|Categories=Multimedia;|' ~/.local/share/applications/plex-desktop.desktop
  '';

}

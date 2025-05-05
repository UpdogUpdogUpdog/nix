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
    bottles
    freerdp
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
    echo "Patching plex-desktop.desktop..."
    rm -f ~/.local/share/applications/plex-desktop.desktop

    cp ${pkgs.plex-desktop}/share/applications/plex-desktop.desktop ~/.local/share/applications/plex-desktop.desktop
    sed -i '/^Categories=/c\Categories=AudioVideo;Player;' ~/.local/share/applications/plex-desktop.desktop
  '';
}

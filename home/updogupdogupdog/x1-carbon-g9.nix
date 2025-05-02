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

}

{ config, pkgs, lib, ... }: {

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
    ".local/bin/toggle-cam" = {
        source = ./scripts/toggle-cam.sh;
        executable = true;
    };
  };
}

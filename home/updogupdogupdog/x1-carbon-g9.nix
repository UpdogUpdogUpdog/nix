{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    discord
    spotify

    (stdenv.mkDerivation rec {
      pname = "toggle-cam";  #This seems to be broken? Currently isn't changing the file since 4.19.
      version = "main";

      src = fetchFromGitHub {
        owner = "UpdogUpdogUpdog";
        repo = "toggle-cam";
        rev = "main";
        sha256 = "AHYo29ZlpaIoGTttinX68QJhCW5Kkea1X/Im5Oqgs6c=";
      };

      nativeBuildInputs = [ bash ];

      dontBuild = true;

      installPhase = ''
        mkdir -p $out
        IS_NIXOS=true PREFIX=$out bash ./install.sh
      '';
    })
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
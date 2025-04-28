{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    discord
    spotify

    (stdenv.mkDerivation rec {
      pname = "toggle-cam";  #This seems to be ? Currently isn't changing the file since 4.19.
      version = "main";

      src = fetchFromGitHub {
        owner = "UpdogUpdogUpdog";
        repo = "toggle-cam";
        rev = "main";
        #sha256 = lib.fakeSha256;
        sha256 = "sha256-3lxwcaPz9l9MPsLVW6AZCskeWIl4GJcG6uGDJkY1zQs=";
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
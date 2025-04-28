{ stdenv, fetchFromGitHub, bash }:

stdenv.mkDerivation rec {
  pname = "toggle-cam";
  version = "main";

  src = fetchFromGitHub {
    owner = "UpdogUpdogUpdog";
    repo = "toggle-cam";
    rev = "main";
    sha256 = "1zgjpswfw6q6px38mh8r116dwfhwx56zdd9lw6z18vsb76xy7d21"; # update with prefetched
  };

  nativeBuildInputs = [ bash ];
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/48x48/apps
    mkdir -p $out/lib/systemd/user

    install -Dm755 bin/toggle-cam.sh $out/bin/toggle-cam
    install -Dm644 share/applications/toggle-cam.desktop $out/share/applications/toggle-cam.desktop
    install -Dm644 share/icons/hicolor/48x48/apps/toggle-cam.png $out/share/icons/hicolor/48x48/apps/toggle-cam.png
    install -Dm644 share/icons/on_toggle-cam.png $out/share/icons/on_toggle-cam.png
    install -Dm644 share/icons/off_toggle-cam.png $out/share/icons/off_toggle-cam.png

    # Install cam-status.sh
    install -Dm755 bin/cam-status.sh $out/bin/cam-status.sh
  '';
}

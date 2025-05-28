{ stdenv, fetchurl, lib, makeWrapper, steam-run, webkitgtk }:

stdenv.mkDerivation rec {
  pname = "playdate-sdk";
  version = "2.7.3"; # Update this to the latest version as needed

  src = fetchurl {
    url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
    # Replace with different sha256 if replacing. run below in terminal to calculate
    #nix hash to-sri --type sha256 $(nix-prefetch-url --unpack https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-latest.tar.gz)
    sha256 = "sha256-Zc9J5np1a88pCHvktK7jUnNCtx/369dXfea2vJf3DWo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/playdate-sdk
    cp -r * $out/share/playdate-sdk
    install -Dm755 $out/share/playdate-sdk/bin/pdc $out/bin/pdc
    install -Dm755 $out/share/playdate-sdk/bin/pdutil $out/bin/pdutil
    makeWrapper ${steam-run}/bin/steam-run $out/bin/PlaydateSimulator \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ webkitgtk ]} \
      --append-flags $out/share/playdate-sdk/bin/PlaydateSimulator
    mkdir -p $out/include
    cp -r $out/share/playdate-sdk/C_API/pd_api $out/include/pd_api
    cp $out/share/playdate-sdk/C_API/pd_api.h $out/include/pd_api.h
    mkdir -p $out/etc/udev/rules.d
    cp $out/share/playdate-sdk/Resources/50-playdate.rules $out/etc/udev/rules.d/
    install -Dm644 $out/share/playdate-sdk/Resources/date.play.simulator.svg $out/share/icons/hicolor/scalable/apps/PlaydateSimulator.svg
    runHook postInstall
  '';

  meta = with lib; {
    description = "PlayDate SDK";
    homepage = "https://play.date/dev/";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
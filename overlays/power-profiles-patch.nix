final: prev: {
  power-profiles-daemon = prev.power-profiles-daemon.overrideAttrs (old: {
    postInstall = old.postInstall or "" + ''
      ln -s $out/share/dbus-1/system-services/net.hadess.PowerProfiles.service \
            $out/share/dbus-1/system-services/org.freedesktop.PowerProfiles.service
    '';
  });
}

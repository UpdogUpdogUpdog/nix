final: prev: {
  power-profiles-daemon = prev.power-profiles-daemon.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      tgt="$out/share/dbus-1/system-services/org.freedesktop.PowerProfiles.service"
      src="$out/share/dbus-1/system-services/net.hadess.PowerProfiles.service"

      if [ ! -e "$tgt" ]; then
        ln -s "$(basename "$src")" "$tgt"
      fi
    '';
  });
}

{ config, lib, pkgs, ... }:

{
  systemd.user.services.cam-status = {
    Unit = {
      Description = "Camera status watcher via udev";
    };
    Service = {
      ExecStart = "${pkgs.toggle-cam}/bin/cam-status.sh";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

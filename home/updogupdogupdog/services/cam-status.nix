{ config, lib, pkgs, ... }:

{
  systemd.user.services.cam-status = {
    Unit = {
      Description = "Camera status watcher via udev";
    };
    Service = {
      ExecStart = "/usr/bin/env bash ${pkgs.toggle-cam}/bin/cam-status.sh";
      Restart = "always";
      RestartSec = "15s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

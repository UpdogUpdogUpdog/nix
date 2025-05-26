{ config, lib, pkgs, ... }: {
  
  nixpkgs = {
    config.allowUnfree = true;
  };

  networking.hostName = "vm"; # Define your hostname.

  # Remote Desktop via XRDP
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.audio.enable = true;
  services.xrdp.openFirewall = true;

  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;


  # QEMU guest agent
  services.qemuGuest.enable = true; 
  
   # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
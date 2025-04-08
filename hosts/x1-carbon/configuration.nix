{ config, lib, pkgs, overlays, ... }: {
  
  nixpkgs = {
    config.allowUnfree = true; 
    overlays = overlays;
  };

  networking.hostName = "x1-carbon"; # Define your hostname.


#   environment.etc."X11/xorg.conf.d/99-libinput-custom.conf".text = ''
#     Section "InputClass"
#         Identifier "Custom libinput config"
#         MatchDriver "libinput"
#         MatchIsTouchpad "on"
#         Option "DisableWhileTyping" "true"
#         Option "PalmDetection" "true"
#         Option "PalmMinWidth" "8"
#         Option "PalmMinZ" "100"
#     EndSection
#   '';

  #Bluetooth
  hardware.bluetooth.enable = true;
  #services.blueman.enable = true; # GTK UI for managing BT (works fine in KDE too)
  hardware.bluetooth.powerOnBoot = false;

  # Filesystem
  systemd.tmpfiles.rules = [
    "d /data 0755 root root -"
    "d /data/Downloads 0755 updogupdogupdog users -"
  ];

  # Fingerprint reader
  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = false;
    sudo.fprintAuth = true;
    sddm.fprintAuth = false;  # If you're using SDDM with KDE Plasma
    kscreenlocker.fprintAuth = true;
  };

  services.tlp.enable = false;
  programs.auto-cpufreq.enable = false;
  # optionally, you can configure your auto-cpufreq settings, if you have any
  # programs.auto-cpufreq.settings = {
  #   charger = {
  #     governor = "performance";
  #     turbo = "always";
  #   };

  #   battery = {
  #     governor = "powersave";
  #     turbo = "auto";
  #   };
  # };

  
  environment.systemPackages = with pkgs; [
    power-profiles-daemon
    spotify
    discord
    touchegg
    libinput
    # steam is a program below, not a package
  ];

  services.fwupd.enable = true;

  services.power-profiles-daemon.enable = true;
  
  services.dbus.packages = [
    pkgs.power-profiles-daemon
  ];

  services.libinput.enable = true;
  services.touchegg.enable = false;
  
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libglvnd           # GL vendor-neutral dispatch library
      ];
    };
  };

  hardware.steam-hardware.enable = true;
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
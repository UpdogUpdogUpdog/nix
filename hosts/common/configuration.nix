{ config, lib, pkgs, ... }: {

  nixpkgs = {
    config.allowUnfree = true; 
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.xautolock.time = 0;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = "neofetch";
    shellInit = ''
      fish_add_path ~/.local/bin
    '';
    shellAliases = {
      ll = "ls -alh";
    };
  };

  programs.command-not-found.enable = false; 
  programs.nix-index.enable = true;
  programs.nix-index.enableFishIntegration = true;

  users.defaultUserShell = pkgs.fish;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "updogupdogupdog" ];
  };

  users.users.updogupdogupdog = {
    isNormalUser = true;
    description = "Updog";
    extraGroups = [ "networkmanager" "wheel" "onepassword-secrets"];
  };

  users.groups.mygroup = {
    name = "onepassword-secrets";
  };

  security.sudo.wheelNeedsPassword = false;
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "updogupdogupdog";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      vaapiIntel
      libvdpau-va-gl
      mesa
      vulkan-loader
    ];
  };

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.loader.systemd-boot.configurationLimit = 3;

  swapDevices = [{
    device = "/swapfile";
    size = 8192;
  }];

  # Enable NFS
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true; # needed for NFS

  fileSystems."/mnt/LIBRARY01" = {
    device = "192.168.1.36:/mnt/user/LIBRARY01";
    fsType = "nfs";
    options = [
      "hard"
      "timeo=50"
      "retrans=5"
      "relatime"
      "rsize=1048576"
      "wsize=1048576"
      "x-systemd.automount"
      "noauto"
    ];
  };


  environment.systemPackages = with pkgs; [
    fish
    gh
    git
    home-manager
    iotop
    jq
    mlocate
    neofetch
    ncdu
    oh-my-fish
    powertop
    screen
    vim
    wget
  ];

  environment.etc."brave/policies/managed/1password.json".text = builtins.toJSON {
    ExtensionInstallForcelist = [
      "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx"
    ];
  };

  services.locate.package = pkgs.mlocate;
  services.locate.enable = true;

  system.stateVersion = "24.11";
}

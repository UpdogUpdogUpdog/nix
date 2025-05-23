# Edit this configuration file to define what should be installed on
# each system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }: {

  nixpkgs = {
    config.allowUnfree = true; 
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant. Often available by default.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.xautolock.time = 0;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  ## Remote Desktop via XRDP
  #services.xrdp.enable = true;
  #services.xrdp.defaultWindowManager = "startplasma-x11";
  #services.xrdp.audio.enable = true;
  #services.xrdp.openFirewall = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  #services.xserver.libinput = {
  #  enable = true;
  #  touchpad = {
  #    disableWhileTyping = true;
  #    naturalScrolling = true; 
  #    palmDetection = true;
  #  };
  #};

  # Shell Stuff
  # Fish
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

  # Default shell for all users
  users.defaultUserShell = pkgs.fish;

  # Password Managers
  # 1password
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ "updogupdogupdog" ];
    };

    # services.onepassword-secrets = {
    #   enable = false;
    #   users = [ "updogupdogupdog" ];  # Users that need secret access
    #   tokenFile = "/etc/opnix-token";  # Default location
    #   configFile = builtins.toFile "empty-op-secrets.json" ''
    #     { "secrets": [] }
    #   '';
    #   # outputDir = "/var/lib/opnix/secrets";  # Optional, this is the default
    # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.updogupdogupdog = {
    isNormalUser = true;
    description = "Updog";
    extraGroups = [ "networkmanager" "wheel" "onepassword-secrets"];
    #packages = with pkgs; [
    #  kdePackages.kate
    #  thunderbird
    #];
  };

  users.groups.mygroup = {
    name = "onepassword-secrets";
  };

  # Allow wheel users to sudo without password entry
  security.sudo.wheelNeedsPassword = false;
  # Enable automatic login for the user.

  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "updogupdogupdog";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver   # Modern Intel Vulkan (ANV)
      vaapiIntel           # Just in case
      libvdpau-va-gl       # Video acceleration fallback
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      vaapiIntel
      libvdpau-va-gl
      mesa                 # 32-bit OpenGL support
      vulkan-loader        # 32-bit Vulkan ICD loader
    ];
  };

  nix.settings.auto-optimise-store = true;

  nix.gc = {
    automatic = true;
    dates = "weekly"; # or "daily", "monthly", 
    options = "--delete-older-than 7d"; # optional, for keeping some history
  };

  boot.loader.systemd-boot.configurationLimit = 3; # Keep the last 3 nixos generations.

  swapDevices = [{
    device = "/swapfile";
    size = 8192; # 8GB, or change if you want more/less
  }];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #_1password-cli
    #_1password-gui
    #brave
    fish
    gh
    git
    home-manager
    iotop
    jq
    #kdePackages.isoimagewriter
    #kdialog
    #mission-center
    mlocate
    neofetch
    ncdu
    oh-my-fish
    powertop
    screen
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #vscode
    wget
  ];

  # Brave Extensions
  environment.etc."brave/policies/managed/1password.json".text = builtins.toJSON {
  ExtensionInstallForcelist = [
    "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx"
  ];
};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # mlocate
  services.locate.package = pkgs.mlocate;
  services.locate.localuser = null;
  services.locate.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
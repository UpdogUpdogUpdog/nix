# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, ... }:

#home-manager nixos module Installation
let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz;

  pkgs = import <nixpkgs> {
    config.allowUnfree = true;
    system = builtins.currentSystem;
  };
in
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    (import "${home-manager}/nixos")
  ];

  nixpkgs = {
    config.allowUnfree = true;
  };
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  programs.command-not-found.enable = false; 


  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Remote Desktop via XRDP
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.audio.enable = true;
  services.xrdp.openFirewall = true;

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

  # Filesystem
  systemd.tmpfiles.rules = [
    "d /data 0755 root root -"
  ];

  # Shells
  # Fish
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = "neofetch";

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.updogupdogupdog = {
    isNormalUser = true;
    description = "Updog";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };

  home-manager.users.updogupdogupdog = { ... }:  let
    fetchSSHKeyScript = pkgs.writeShellScript "fetch-ssh-key" ''
      set -e
      
      env | sort > /tmp/env.systemd.txt

      echo "[ssh-key-from-1password] Waiting for 1Password native messaging socket..."

      SOCKET_PATH="$XDG_RUNTIME_DIR/1password/native-messaging-socket"
      TIMEOUT=30
      COUNT=0

      while [ ! -S "$SOCKET_PATH" ]; do
        sleep 1
        COUNT=$((COUNT + 1))
        if [ "$COUNT" -ge "$TIMEOUT" ]; then
          echo "Timeout waiting for 1Password socket at $SOCKET_PATH"
          exit 1
        fi
      done

      echo "[ssh-key-from-1password] Socket ready. Fetching SSH keys..."
      mkdir -p ~/.ssh
      ${pkgs._1password-cli}/bin/op read "op://Private/Updog GitHub SSH Key/id_ed25519" > ~/.ssh/id_ed25519
      ${pkgs._1password-cli}/bin/op read "op://Private/Updog GitHub SSH Key/id_ed25519.pub" > ~/.ssh/id_ed25519.pub
      chmod 600 ~/.ssh/id_ed25519
      chmod 644 ~/.ssh/id_ed25519.pub
    '';
  in {
    # Packages
    home.packages = with pkgs; [ steam ];

    # Programs
    programs.firefox.enable = false;
    programs.git = {
        enable = true;
        userName = "Updog";
        userEmail = "me@updog.cool";
    };
    programs.fish = {
      functions.rebuild = ''
        function rebuild
          sudo nixos-rebuild switch -I nixos-config='/home/updogupdogupdog/Git Repositories/nix/configuration.nix'
          and git -C '/home/updogupdogupdog/Git Repositories/nix' add .
          and git -C '/home/updogupdogupdog/Git Repositories/nix' commit -am "Rebuild: \$(date +%F_%T)"
          and git -C '/home/updogupdogupdog/Git Repositories/nix' push
        end
      '';
    };

    systemd.user.services.ssh-key-from-1password = {
      Unit = {
        Description = "Fetch SSH key from 1Password CLI";
        After = [ "default.target" ];
      };

      Service = {
        Type = "oneshot";
        Environment = [
          "XDG_RUNTIME_DIR=%t"
          "PATH=${pkgs._1password-cli}/bin:/run/wrappers/bin:/etc/profiles/per-user/updogupdogupdog/bin:/run/current-system/sw/bin"
        ];
        ExecStart = [ fetchSSHKeyScript ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.11";

  };

  # Enable automatic login for the user.
  #services.displayManager.autoLogin.enable = true;
  #services.displayManager.autoLogin.user = "updogupdogupdog";

  # Allow wheel users to sudo without password entry
  security.sudo.wheelNeedsPassword = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    gh
    git
    screen
    brave
    neofetch
    fish
    kitty
    mlocate
    vscode
    _1password-cli
    _1password-gui
    home-manager
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

  # List services that you want to enable:

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

  # QEMU guest agent
  services.qemuGuest.enable = true; 

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}

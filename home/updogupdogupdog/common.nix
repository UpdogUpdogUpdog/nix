{ config, pkgs, ... }: {

# Packages
home.packages = with pkgs; [
  _1password-cli
  _1password-gui
  brave
  kdePackages.isoimagewriter
  kdialog
  mission-center
  vscode
  kdePackages.kate
];



# Programs
programs.firefox.enable = false;
programs.git = {
  enable = true;
  userName = "Updog";
  userEmail = "me@updog.cool";
  extraConfig = {
    url."git@github.com:".insteadOf = "https://github.com/";
  };
};  

programs.plasma = {
  enable = true;
  workspace = {
    theme = "breeze-dark";
  };
};

gtk = {
  enable = true;
  theme = {
    name = "Breeze-Dark";
    package = pkgs.libsForQt5.breeze-gtk;
  };
};

#Files
home.file = {
  ".local/bin/rebuild" = {
    source = ./scripts/rebuild.fish;
    executable = true;
  };
  ".local/bin/gen-opnix-token" = {
    source = ./scripts/gen-opnix-token.sh;
    executable = true;
  };

};

programs.onepassword-secrets = {
  enable = true;
  secrets = [
    {
      # Paths are relative to home directory
      path = ".ssh/github-id_ed25519";
      reference = "op://SSH Keys/Updog GitHub SSH Key/private key";
    }
  ];
};

programs.ssh = {
  enable = true;
  matchBlocks."github.com" = {
    user = "git";
    identityFile = "~/.ssh/github-id_ed25519";
    identitiesOnly = true;
  };
};


xdg.mimeApps = {
  enable = true;
  defaultApplications = {
    "x-scheme-handler/api" = [ "brave-browser.desktop" ];
    "x-scheme-handler/unity" = [ "brave-browser.desktop" ];
  };
};

home-manager.backupFileExtension = ".bak";

# The state version is required and should stay at the version you
# originally installed.
home.stateVersion = "24.11";

}

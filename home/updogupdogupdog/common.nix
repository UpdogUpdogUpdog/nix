{ config, pkgs, ... }: {

# Packages

# Programs
programs.firefox.enable = false;
programs.git = {
    enable = true;
    userName = "Updog";
    userEmail = "me@updog.cool";
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
      reference = "op://SSH Keys/Updog GitHub SSH Key/id_ed25519";
    }
  ];
};

# The state version is required and should stay at the version you
# originally installed.
home.stateVersion = "24.11";

}

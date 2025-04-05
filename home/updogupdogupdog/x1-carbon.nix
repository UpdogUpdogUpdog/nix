{ config, pkgs, ... }: {

# Packages
home.packages = with pkgs; [
  steam
  ];

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
home.file.".local/bin/rebuild" = {
  source = ./scripts/rebuild.fish;
  executable = true;
};


# The state version is required and should stay at the version you
# originally installed.
home.stateVersion = "24.11";

}

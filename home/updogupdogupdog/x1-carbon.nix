{ config, pkgs, ... }: {
# Packages
home.packages = with pkgs; [ steam ];

# Programs
programs.firefox.enable = false;
programs.git = {
    enable = true;
    userName = "Updog";
    userEmail = "me@updog.cool";
};

#Files
home.file.".config/fish/functions/rebuild.fish".source = ./scripts/rebuild.fish;


# The state version is required and should stay at the version you
# originally installed.
home.stateVersion = "24.11";

}

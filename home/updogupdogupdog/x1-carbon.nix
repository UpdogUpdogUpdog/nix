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

# The state version is required and should stay at the version you
# originally installed.
home.stateVersion = "24.11";

}

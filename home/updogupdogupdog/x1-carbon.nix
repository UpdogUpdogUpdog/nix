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

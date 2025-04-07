#!/usr/bin/env fish

set -l repo ~/Git\ Repositories/nix
set -l host (hostname)
set -l user (whoami)
set -l do_nixos 1
set -l do_home 1

# Parse args
for arg in $argv
    switch $arg
        case --nixos
            set do_home 0
        case --home
            set do_nixos 0
        case '*'
            echo "Usage: rebuild [--nixos|--home]"
            exit 1
    end
end

echo "🔍 Validating config before rebuild..."

# Test nixos build
if test $do_nixos -eq 1
    echo "→ Testing NixOS build..."
    if ! nixos-rebuild build --flake $repo#$host 2> /tmp/nixos-build.log
        echo "❌ NixOS build failed:"
        tail -n 30 /tmp/nixos-build.log | sed '/^$/d' | head -n 15
        exit 1
    end
end

# Test home-manager build
if test $do_home -eq 1
    echo "→ Testing Home Manager build..."
    if ! home-manager build --flake $repo#$user@$hostname 2> /tmp/home-build.log
        echo "❌ Home Manager build failed:"
        tail -n 30 /tmp/home-build.log | sed '/^$/d' | head -n 15
        exit 1
    end
end

echo "✅ Build successful. Applying changes..."

# Switch!
if test $do_nixos -eq 1
    echo "→ Switching NixOS..."
    sudo nixos-rebuild switch --flake $repo#$hostname
end

if test $do_home -eq 1
    echo "→ Switching Home Manager..."
    echo "Checking for /home/$user/.gtkrc-20"
    ll /home/$user/.gtkrc-2.0*
    mv /home/$user/.gtkrc-2.0 /home/$user/.gtkrc-2.0.bak
    echo "Removed?"
    ll /home/$user/.gtkrc-2.0*
    home-manager switch --flake $repo#$user@$hostname
end

# Prompt for commit message
echo "Enter commit message [default: auto: successful rebuild on (hostname)]: "
read user_msg
if test -z "$user_msg"
    set user_msg "auto: successful rebuild on (hostname)"
end

# Auto commit
echo "📦 Committing and pushing config changes..."
cd $repo
git add .
git commit -m "$user_msg"
and git push
cd -

echo "🎉 Rebuild complete!"

#!/usr/bin/env fish

set -l repo ~/Git\ Repositories/nix
set -l hostname (hostname)
set -l user updogupdogupdog
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
    if ! nixos-rebuild build --flake $repo#$hostname 2> /tmp/nixos-build.log
        echo "❌ NixOS build failed:"
        tail -n 30 /tmp/nixos-build.log | sed '/^$/d' | head -n 15
        exit 1
    end
end

# Test home-manager build
if test $do_home -eq 1
    echo "→ Testing Home Manager build..."
    if ! home-manager build --flake $repo#$user 2> /tmp/home-build.log
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
    home-manager switch --flake $repo#$user
end

# Auto commit
echo "📦 Committing and pushing config changes..."
cd $repo
git add .
git commit -m "auto: successful rebuild on $hostname"
git push

echo "🎉 Rebuild complete!"

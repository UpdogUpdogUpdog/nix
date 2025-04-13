#!/usr/bin/env fish

set -l repo ~/Git\ Repositories/nix
set -l host (hostname)
set -l user (whoami)
set -l do_nixos 1
set -l do_home 1
set token_file /etc/opnix-token
set gen_script ~/.local/bin/gen-opnix-token

# Check if token file exists.
if test -f $token_file
    # Get last modification time (seconds since epoch) of the token file.
    set mod_time (stat -c %Y $token_file)
    # Get current time (seconds since epoch).
    set current_time (date +%s)
    # Calculate age of the token.
    set diff (math $current_time - $mod_time)
    if test $diff -gt 86400
        echo "Token is older than 24 hours, regenerating..."
        $gen_script
    else
        echo "Token is fresh."
    end
else
    echo "Token file doesn't exist, generating token..."
    $gen_script
end

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
    if ! home-manager build --flake $repo#$user@$host 2> /tmp/home-build.log
        echo "❌ Home Manager build failed:"
        tail -n 30 /tmp/home-build.log | sed '/^$/d' | head -n 15
        exit 1
    end
end

echo "✅ Build successful. Applying changes..."

# Switch!
if test $do_nixos -eq 1
    echo "→ Switching NixOS..."
    sudo nixos-rebuild switch --flake $repo#$host 
end

if test $do_home -eq 1
    echo "→ Switching Home Manager..."
    echo "Checking for /home/$user/.gtkrc-20"
    ll /home/$user/.gtkrc-2.0*
    mv /home/$user/.gtkrc-2.0 /home/$user/.gtkrc-2.0.bak
    echo "Removed?"
    ll /home/$user/.gtkrc-2.0*
    home-manager switch --flake $repo#$user@$host 
end

# Prompt for commit message
echo "Enter commit message [default: auto: successful rebuild on $host]: "
read user_msg
if test -z "$user_msg"
    set user_msg "auto: successful rebuild on $host"
end

# Auto commit
echo "📦 Committing and pushing config changes..."
cd $repo
git add .
git commit -m "$host: $user_msg"
and git push
cd -

echo "🎉 Rebuild complete!"

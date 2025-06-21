#!/usr/bin/env fish

set -l repo ~/Git\ Repositories/nix
set -l host (hostname)
set -l user (whoami)
set -l do_nixos 1
set -l do_home 1
set -l upgrade 0
set -l token_file /etc/opnix-token
set -l gen_script ~/.local/bin/gen-opnix-token
set -l work_branch dev

# Parse args
for arg in $argv
    switch $arg
        case --nixos
            set do_home 0
        case --home
            set do_nixos 0
        case --upgrade
            set upgrade 1
        case '*'
            echo "Usage: rebuild [--nixos|--home|--upgrade]"
            exit 1
    end
end

cd $repo

# Confirm we are on the dev branch
set -l current_branch (git rev-parse --abbrev-ref HEAD)
if test $current_branch != $work_branch
    echo "❌ You are not on the '$work_branch' branch. Please switch to it first."
    exit 1
end

# Prompt for commit message first
echo "💬 Enter commit message for changes in $work_branch: "
read user_msg
if test -z "$user_msg"
    set user_msg "auto: rebuild attempt on $host"
end

# Stage all and commit
git add .
git commit -m "$host: $user_msg"
git push origin $work_branch

# Token rotation
if test -f $token_file
    set mod_time (stat -c %Y $token_file)
    set current_time (date +%s)
    set diff (math $current_time - $mod_time)
    if test $diff -gt 86400
        echo "🔑 Token is stale, regenerating..."
        $gen_script
    else
        echo "🔑 Token is fresh."
    end
else
    echo "🔑 Token file missing, generating..."
    $gen_script
end

# Prefetch toggle-cam sha256
echo "📦 Prefetching toggle-cam SHA..."
set -l new_sha (nix-prefetch-url --unpack https://github.com/UpdogUpdogUpdog/toggle-cam/archive/refs/heads/main.tar.gz)
if test $status -eq 0
    echo "✅ Got new toggle-cam sha256: $new_sha"
    sed -i "s|sha256 = \".*\";|sha256 = \"$new_sha\";|" $repo/packages/toggle-cam/default.nix
else
    echo "❌ Failed to prefetch toggle-cam SHA."
    exit 1
end

# Upgrade flake inputs if requested
if test $upgrade -eq 1
    echo "🚀 Upgrading flake inputs..."
    nix flake update
    git add flake.lock
    git commit -m "$host: auto: flake inputs upgraded"
    git push origin $work_branch
end

# Test nixos build
if test $do_nixos -eq 1
    echo "🔨 Testing NixOS build..."
    if ! nixos-rebuild build --flake $repo#$host 2> /tmp/nixos-build.log
        echo "❌ NixOS build failed:"
        tail -n 30 /tmp/nixos-build.log | sed '/^$/d' | head -n 50
        echo "💥 Rebuild failed. Fix it up on $work_branch and try again."
        exit 1
    end
end

# Test home-manager build
if test $do_home -eq 1
    echo "🔨 Testing Home Manager build..."
    if ! home-manager build --flake $repo#$user@$host 2> /tmp/home-build.log
        echo "❌ Home Manager build failed:"
        tail -n 30 /tmp/home-build.log | sed '/^$/d' | head -n 50
        echo "💥 Rebuild failed. Fix it up on $work_branch and try again."
        exit 1
    end
end

# Apply config
if test $do_nixos -eq 1
    echo "💻 Switching NixOS config..."
    sudo nixos-rebuild switch --flake $repo#$host
end

if test $do_home -eq 1
    echo "🏠 Switching Home Manager config..."
    home-manager switch --flake $repo#$user@$host
    home-manager expire-generations "-3 days"
end

# Cleanup
echo "🧹 Cleaning up..."
find $repo -type l -name result -delete
find ~ -type l -name result -delete
sudo find /nix/var/nix/gcroots/auto -type l -exec readlink -f {} \; | grep '^/tmp/' | xargs -r sudo rm -f
sudo nix-collect-garbage -d

# Merge into main
git checkout main
git merge $work_branch --no-edit
git push origin main
git checkout $work_branch

# Excessive success message
echo ""
echo "🌈💥💻🔥💾🚀💅🦄"
echo "💯 REBUID AND SWITCH SUCCESSFUL 💯"
echo "🎉"
echo "✔️ Changes committed to dev, merged to main, and pushed remotely"
echo "🌈💥💻🔥💾🚀💅🦄"
echo ""

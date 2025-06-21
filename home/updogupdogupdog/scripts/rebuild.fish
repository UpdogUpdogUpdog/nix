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

# Confirm we're on dev branch
set -l current_branch (git rev-parse --abbrev-ref HEAD)
if test $current_branch != $work_branch
    echo "❌ You are not on the '$work_branch' branch. Please switch to it first."
    exit 1
end

# Prompt for commit message
echo "💬 Enter commit message for changes in $work_branch: "
read user_msg
if test -z "$user_msg"
    set user_msg "auto: rebuild attempt on $host"
end

# 🔐 Token freshness check
if test -f $token_file
    set mod_time (stat -c %Y $token_file)
    set current_time (date +%s)
    set diff (math $current_time - $mod_time)
    if test $diff -gt 86400
        echo "🔑 Token is older than 24 hours, regenerating..."
        $gen_script
    else
        echo "🔑 Token is fresh."
    end
else
    echo "🔑 Token file doesn't exist, generating token..."
    $gen_script
end

# Stage + commit to dev
git add .
git commit -m "$host: $user_msg"
git push origin $work_branch

# Upgrade flake inputs (if requested)
if test $upgrade -eq 1
    echo "🚀 Upgrading flake inputs..."
    nix flake update
    git add flake.lock
    git commit -m "$host: auto: flake inputs upgraded"
    git push origin $work_branch
end

# Prefetch updated toggle-cam SHA
echo "🔍 Prefetching toggle-cam sha256..."
set -l new_sha (nix-prefetch-url --unpack https://github.com/UpdogUpdogUpdog/toggle-cam/archive/refs/heads/main.tar.gz)
if test $status -eq 0
    echo "✅ Got new toggle-cam sha256: $new_sha"
    echo "🔄 Updating toggle-cam/default.nix with new sha256..."
    sed -i "s|sha256 = \".*\";|sha256 = \"$new_sha\";|" $repo/packages/toggle-cam/default.nix
else
    echo "❌ Failed to prefetch toggle-cam tarball."
    exit 1
end

# Dry test system build
if test $do_nixos -eq 1
    echo "🔨 Testing NixOS build..."
    if ! nixos-rebuild build --flake $repo#$host 2> /tmp/nixos-build.log
        echo "❌ NixOS build failed:"
        tail -n 30 /tmp/nixos-build.log | sed '/^$/d' | head -n 50
        echo "💥 Rebuild failed. Stay on $work_branch and fix it up."
        exit 1
    end
end

# Dry test home-manager build
if test $do_home -eq 1
    echo "🔨 Testing Home Manager build..."
    if ! home-manager build --flake $repo#$user@$host 2> /tmp/home-build.log
        echo "❌ Home Manager build failed:"
        tail -n 30 /tmp/home-build.log | sed '/^$/d' | head -n 50
        echo "💥 Rebuild failed. Stay on $work_branch and fix it up."
        exit 1
    end
end

# === Switch config if both builds succeeded ===

if test $do_nixos -eq 1
    echo "💻 Switching NixOS..."
    sudo nixos-rebuild switch --flake $repo#$host
end

if test $do_home -eq 1
    echo "🏠 Switching Home Manager..."
    home-manager switch --flake $repo#$user@$host
    home-manager expire-generations "-3 days"
end

# === Cleanup ===

echo "🧹 Cleaning up stale build artifacts and temp roots..."
find $repo -type l -name result -delete
find ~ -type l -name result -delete
sudo find /nix/var/nix/gcroots/auto -type l \
    -exec readlink -f {} \; | grep '^/tmp/' | \
    xargs -r sudo rm -f
sudo nix-collect-garbage -d

# === Merge to main and push ===

git checkout main
git merge $work_branch --no-edit
git push origin main
git checkout $work_branch

# 🎉 Success
echo ""
echo "🌈💥💻🔥💾🚀💅🦄"
echo "💯 SYSTEM REBUILT, SWITCHED, AND BLESSED."
echo "✔️  Changes committed to $work_branch, merged to main, and pushed like a boss."
echo "🥂 You may now close your laptop and go touch grass."
echo "🌈💥💻🔥💾🚀💅🦄"
echo ""

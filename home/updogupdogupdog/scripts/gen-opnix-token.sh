#!/usr/bin/env bash
set -euo pipefail

VAULT_NAME="SSH Keys"
ITEM_NAME="Updog GitHub SSH Key"
TOKEN_PATH="/etc/opnix-token"
ACCOUNT_NAME="opnix-updog"

# Check if 1password is running
if ! pgrep -x "1password" > /dev/null; then
    1password --silent &> /dev/null &
    set launched 1
fi

# Wait until the CLI can actually connect
while ! op vault list &>/dev/null; do
    echo "[!] Not signed in. Make sure the 1Password app is open and you're logged in."
    sleep 2
done

echo "[*] Signing in to 1Password CLI..."
op signin --account my.1password.com

echo "[*] Creating service account (you may be prompted)..."
TOKEN=$(op service-account create \
    "$ACCOUNT_NAME" \
    --vault "$VAULT_NAME:read_items" \
    --expires-in 24h \
    --format json | jq -r .token)

echo "[*] Writing token to $TOKEN_PATH..."
sudo install -Dm600 /dev/stdin "$TOKEN_PATH" <<< "$TOKEN"
sudo chown updogupdogupdog:onepassword-secrets $TOKEN_PATH

echo "[+] Token written. Try 'opnix list' or 'home-manager switch' now."

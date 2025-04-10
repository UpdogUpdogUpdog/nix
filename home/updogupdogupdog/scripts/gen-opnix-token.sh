#!/usr/bin/env bash
set -euo pipefail

VAULT_NAME="private"
ITEM_NAME="Updog GitHub SSH Key"
TOKEN_PATH="/etc/1password/opnix-token"
ACCOUNT_NAME="opnix-updog"

echo "[*] Signing in to 1Password CLI..."
op signin --account my.1password.com

echo "[*] Creating service account (you may be prompted)..."
TOKEN=$(op service-account create \
    --name "$ACCOUNT_NAME" \
    --vault "$VAULT_NAME" \
    --permissions "item:read" \
    --expiry 90d \
    --format json | jq -r .token)

echo "[*] Writing token to $TOKEN_PATH..."
sudo install -Dm600 /dev/stdin "$TOKEN_PATH" <<< "$TOKEN"

echo "[+] Token written. Try 'opnix list' or 'home-manager switch' now."

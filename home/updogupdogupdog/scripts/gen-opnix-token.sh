#!/usr/bin/env bash
set -euo pipefail

VAULT_NAME="SSH Keys"
ITEM_NAME="Updog GitHub SSH Key"
TOKEN_PATH="/etc/opnix-token"
ACCOUNT_NAME="opnix-updog"

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

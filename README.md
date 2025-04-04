# nix


# 🧠 Nix Flake Cheat Sheet for Future Me (aka updog)

You're using a flake-based Nix config at:  
https://github.com/UpdogUpdogUpdog/nix

This doc is for when you forget how the hell to use it.

---

## 🧼 After Fresh NixOS Install: Bootstrap System

1. Log in as your user (`updogupdogupdog`)
2. Run this one-liner:

```bash
nix-shell -p git nix home-manager --run 'git clone https://github.com/UpdogUpdogUpdog/nix ~/nix && cd ~/nix && nixos-rebuild switch --flake .#$(hostname) && home-manager switch --flake .#updogupdogupdog@$(hostname)'
```

---

## 🖥️ Add a New Machine

1. Create a new file:

`hosts/new-box/configuration.nix`

Example contents:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
  ];

  networking.hostName = "new-box";
  # Add any machine-specific stuff here
}
```

2. Register the host in `flake.nix`:

```nix
nixosConfigurations."new-box" = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [ ./hosts/new-box/configuration.nix ];
};
```

3. Deploy on the new box:

```bash
nix-shell -p git nix home-manager --run 'git clone https://github.com/UpdogUpdogUpdog/nix ~/nix && cd ~/nix && nixos-rebuild switch --flake .#new-box && home-manager switch --flake .#updogupdogupdog@new-box'
```

---

## 🔁 Redeploy an Existing Machine

On the machine:

```bash
cd ~/nix
git pull
sudo nixos-rebuild switch --flake .#$(hostname)
home-manager switch --flake .#updogupdogupdog@$(hostname)
```

Or from another machine:

```bash
nixos-rebuild switch --flake .#hostname --target-host root@hostname
```

---

## ➕ Add Software to One Machine

Edit `hosts/your-machine/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  firefox
  htop
];
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#your-machine
```

---

## ➕ Add Software to Every Machine

Edit your shared config (e.g. `common.nix`):

```nix
environment.systemPackages = with pkgs; [
  neovim
  git
];
```

Make sure all hosts import `common.nix`:

```nix
imports = [
  ../common.nix
];
```

Then redeploy on each machine:

```bash
sudo nixos-rebuild switch --flake .#hostname
```

---

## 🧠 Memory Anchors

- Home Manager target:  
  `home-manager switch --flake .#updogupdogupdog@hostname`

- NixOS system target:  
  `nixos-rebuild switch --flake .#hostname`

- Never edit `/etc/nixos` — everything lives in the repo  
- Bring new `hardware-configuration.nix` into `hosts` directories from local `/etc/nixos`. 
- Commit and push your changes. Always.

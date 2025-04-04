#This is a minimal home-manager config we can switch to just for troubleshooting build problems and other things.

{ config, pkgs, ... }:

{
  home.username = "updogupdogupdog";
  home.homeDirectory = "/home/updogupdogupdog";
  home.stateVersion = "24.11";

  programs.fish.enable = true;
}

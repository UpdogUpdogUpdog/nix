#This is a minimal home-manager config we can switch to just for troubleshooting build problems and other things.

{ config, pkgs, ... }:

{
  home.username = "updogupdogupdog";
  home.homeDirectory = "/home/updogupdogupdog";
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";

  programs.fish.enable = true;
}

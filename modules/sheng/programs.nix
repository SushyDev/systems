{ pkgs, ... }:
{
  programs.nano.enable = false;
  programs.nix-index.enable = false;
  programs.zsh.enable = true;

  # No steam/gamemode here, unlike pc: proton-ge-bin has no aarch64-linux
  # build, and Steam itself is x86-only.
}

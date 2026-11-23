{ lib }:
let
  inherit (import ../../lib/traits { inherit lib; }) mkTraits;
in
mkTraits {
  use1Password = ./1password;
  useDdev = ./ddev;
  useDeterminateNix = ./determinate;
  useDirenv = ./direnv;
  useDotfiles = ./dotfiles;
  useGroupOwnedFlake = ./group-owned-flake;
  useHomeManager = ./home-manager;
  useKde = ./kde;
  useNixSettings = ./nix-settings;
  useNpm = ./npm;
  useOxidation = ./oxidation;
  usePasswordlessSudo = ./passwordless-sudo;
  useSsh = ./ssh;
  useVicinae = ./vicinae;
}

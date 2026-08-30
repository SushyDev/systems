{ pkgs, ... }:
{
  imports = [ ../../shared/nix.nix ];

  # nixos-sheng's nix-bootstrap.nix already enables nix-command and flakes;
  # shared/nix.nix sets the same list, which merges cleanly.
  #
  # keep-outputs/keep-derivations come from shared/nix.nix and are worth
  # watching here: this device has one partition and no swap, so a store
  # that never sheds build inputs fills it faster than it does on pc.
}

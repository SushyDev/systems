{ lib, ... }:
{
  nix.settings = import ./settings.nix { inherit lib; } // {
    auto-optimise-store = lib.mkDefault true;
  };

  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "daily";
    options = lib.mkDefault "--delete-older-than 3d";
  };
}

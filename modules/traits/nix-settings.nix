{ lib, options, ... }:
let
  settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    cores = lib.mkDefault 0;
    max-jobs = lib.mkDefault "auto";
    keep-outputs = lib.mkDefault true;
    keep-derivations = lib.mkDefault true;
    download-buffer-size = lib.mkDefault 2147483648;
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
in
{
  config =
    if options ? determinateNix then
      {
        determinateNix.customSettings = settings;
        determinateNix.determinateNixd.garbageCollector.strategy = lib.mkDefault "automatic";
      }
    else
      {
        nix.settings = settings // {
          auto-optimise-store = lib.mkDefault true;
        };
        nix.gc = {
          automatic = lib.mkDefault true;
          dates = lib.mkDefault "daily";
          options = lib.mkDefault "--delete-older-than 3d";
        };
      };
}

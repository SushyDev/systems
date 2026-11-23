{ lib }:
{
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
}

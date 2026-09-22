{
  use1Password = ./1password;
  useGroupOwnedFlake = import ./group-owned-flake.nix;
  useKde = ./kde.nix;
  useNixSettings = ./nix-settings.nix;
  useOxidation = ./oxidation.nix;
  usePasswordlessSudo = ./passwordless-sudo.nix;
}

{
  config,
  inputs,
  setup,
  pkgs,
  ...
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit inputs setup;
  };

  home-manager.users.sushy = import ./users/sushy/configuration.nix;

  # No services.emacs here, unlike pc: it is a user service that pulls a
  # large closure onto a device with one partition.
}

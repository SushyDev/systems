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

}

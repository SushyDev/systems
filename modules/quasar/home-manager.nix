{
  inputs,
  config,
  ...
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
  home-manager.users.sushy = import ./user/sushy/configuration.nix;
  home-manager.users.work = import ./user/work/configuration.nix;
}

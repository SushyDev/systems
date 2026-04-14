{
  inputs,
  setup,
  config,
  ...
}:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {
    inherit inputs setup;
    systemConfig = config;
  };
  home-manager.users.sushy = import ./user/sushy/configuration.nix;
  home-manager.users.work = import ./user/work/configuration.nix;
}

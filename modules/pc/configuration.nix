{
  setup,
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./packages.nix
    ./programs.nix
    ./security.nix
    ./services.nix

    ./system/default.nix
    ../shared/oxidation.nix
    ../shared/fonts.nix
    ./desktop-manager/kde.nix
    # ./hardening.nix

    inputs.m2-nix-container.nixosModules.default
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  console.earlySetup = true;
  time.timeZone = "Europe/Amsterdam";
  system.stateVersion = "25.05";

  environment.shellAliases = {
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  # Magento 2 Setup - Appie Goossens Instance
  services.magento = {
    enable = true;
    instances.appie-goossens = {
      magentoSrcInput = "appie-goossens-m2";
      dataPath = "/var/lib/containers/magento-appie";
      
      # Override default database name
      mariadb.database = "magento_appie";
    };
  };
}

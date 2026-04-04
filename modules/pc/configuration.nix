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
      networkPrefix = "192.168.100";

      # Database
      mariadb = {
        host = "192.168.101.2";
        port = 3306;
        database = "magento_appie";
        user = "magento";
        password = "magento";
        rootPassword = "magento";
      };

      # Cache
      cache = {
        host = "192.168.102.2";
        port = 6379;
        db = 0;
      };

      # Session
      session = {
        host = "192.168.103.2";
        port = 6379;
        db = 1;
      };

      # OpenSearch
      opensearch = {
        host = "192.168.104.2";
        port = 9200;
      };

      # RabbitMQ
      rabbitmq = {
        host = "192.168.105.2";
        port = 5672;
        user = "guest";
        password = "guest";
      };

      # Nginx
      nginx = {
        host = "192.168.106.2";
        port = 8080;
      };

      # Varnish
      varnish = {
        host = "192.168.107.2";
        port = 6081;
      };
    };
  };
}

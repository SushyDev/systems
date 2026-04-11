{ pkgs, config, ... }:
{
  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = config.networking.hostName;
    easyCerts = true; # Automatically generates certificates
    apiserverAddress = "https://${config.networking.hostName}:6443";

    # Use CoreDNS for service discovery
    addons.dns.enable = true;

    # Required if your server has swap enabled
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  # Make sure the master hostname resolves correctly
  networking.extraHosts = "127.0.0.1 ${config.networking.hostName}";

  # Standard packages for management
  environment.systemPackages = [
    pkgs.kubectl
    pkgs.kubernetes
  ];
}

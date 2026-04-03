{ ... }:
{
  networking.hostName = "pc"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.firewall.allowedTCPPorts = [
    8080
    8081
  ];
}

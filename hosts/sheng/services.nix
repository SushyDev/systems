{ pkgs, ... }:
{
  # nixos-sheng ships drivers only, so these are ours.
  services.openssh.enable = true;
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  # nssmdns6 off: the responder registers IPv4 only, and the missing AAAA
  # costs a resolver timeout per lookup.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.fstrim.enable = true;

  # zram and OOM handling come from sheng.performance (configuration.nix).
  # No earlyoom: it raced systemd-oomd for the same job.

  # Wi-Fi only; NetworkManager pulls it in by default.
  networking.modemmanager.enable = false;

  services.printing.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
}

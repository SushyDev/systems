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

  # 8G soldered, no swap partition.
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  services.earlyoom.enable = true;

  services.printing.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
}

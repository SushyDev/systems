{ pkgs, ... }:
{
  # openssh and NetworkManager are already on from nixos-sheng's
  # hardware.nix, so this only carries what pc adds on top and what makes
  # sense on a battery-powered tablet.

  services.fstrim.enable = true;

  # Memory: 8G of soldered RAM with no swap partition, so both of these
  # earn their place more than they do on pc.
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  services.earlyoom.enable = true;

  services.printing.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Unlike pc: no docker/containers (no room and no reason on the tablet),
  # and tlp is left alone rather than forced off -- this one has a battery.
}

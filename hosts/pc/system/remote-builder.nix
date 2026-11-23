# pc acts as a Nix build machine for sheng (Xiaomi Pad 6S Pro, aarch64).
#
# sheng runs CONFIG_DRM_MSM=y, so every display-driver change is a full kernel
# rebuild -- roughly twenty minutes on its eight cores.  pc has 24.
#
# Deliberately emulation, NOT cross-compilation.  A cross-built kernel is a
# different derivation with a different store path than a natively-built one,
# so going cross would mean the tablet could no longer build its own kernel at
# all -- it would have to emulate x86_64 to do it.  Emulating aarch64 here
# keeps the derivation identical, so either machine can build it and the
# tablet stays a working fallback when pc is off.
{ pkgs, ... }:
{
  # Lets pc build aarch64-linux derivations; nix picks this up as an
  # extra-platform automatically.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Dedicated least-privilege account for sheng's nix-daemon to log into.
  # It has to be a trusted user (to import derivations and build without
  # signature checks) but needs nothing else: no groups, no sudo.
  users.users.nixremote = {
    isSystemUser = true;
    group = "nixremote";
    createHome = true;
    home = "/var/lib/nixremote";
    # A real shell is required: the remote builder protocol runs
    # 'nix-store --serve' over this account, and nologin refuses it.
    shell = pkgs.bashInteractive;
    description = "Nix remote build account for sheng";
    openssh.authorizedKeys.keys = [
      # /root/.ssh/id_ed25519.pub on sheng.  sheng's nix-daemon runs as root,
      # so it is root's key that belongs here, not sushy's.
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnalgBRS13FY/gyPgD7tuKS6xJLTgE8taREh1nEm8OG root@sheng nix remote builder"
    ];
  };
  users.groups.nixremote = { };

  nix.settings.trusted-users = [ "nixremote" ];

  # The sheng kernel derivation is built with ccacheStdenv, and its wrapper
  # aborts unless CCACHE_DIR exists inside the sandbox.  That requirement
  # travels with the derivation, so a machine building it on sheng's behalf
  # needs the same directory and sandbox exception the tablet has.
  systemd.tmpfiles.rules = [ "d /var/cache/ccache 0770 root nixbld -" ];
  nix.settings.extra-sandbox-paths = [ "/var/cache/ccache" ];
}

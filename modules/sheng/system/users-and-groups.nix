{ setup, pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;

  users.groups."${setup.nixGroupName}" = {
    gid = setup.nixGroupId;
    members = setup.nixGroupMembers;
  };

  users.users."${setup.primaryUser}" = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      # programs._1password-gui creates this; the browser/CLI integration
      # and the SSH agent socket are unreachable without it.
      "onepassword"
    ];
    uid = 1000;

    # Without this the account has NO password, which locks it out of SDDM
    # entirely -- the greeter has nothing to accept. initialHashedPassword
    # rather than hashedPassword so `passwd` on the device sticks instead
    # of being reverted by the next rebuild.
    #
    # This is the same "password" hash nixos-sheng bakes for root. Change
    # it: the hash is in a world-readable store path and is published in
    # that project's README.
    initialHashedPassword = "$6$e/k7.7lhroPMA6hy$ysO.xH9hAm5y0NCdKQs4AAT0MQFy0kP7F6XpVIryRAN1wNHReXXHx21zdonHiXwKuynriN9UA.OQDhhz67atj/";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
    ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
    ];
  };

  # Left deliberately untouched, both from nixos-sheng's hardware.nix:
  #
  #   services.getty.autologinUser = "root"
  #   users.users.root.hashedPassword  (the password is "password")
  #
  # Those are bring-up defaults and they are not safe on a daily driver,
  # but overriding them needs mkForce and a password for ${setup.primaryUser}
  # that exists before first boot -- get that wrong and the tablet has no
  # way in at all. users.mutableUsers is true, so the intended fix is one
  # `passwd` per user over the serial console after the first flash, then
  # mkForce the autologin off here.
}

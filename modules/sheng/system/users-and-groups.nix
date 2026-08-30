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
      # programs._1password-gui creates this; the CLI integration and agent
      # socket need it.
      "onepassword"
    ];
    uid = 1000;

    # No password locks the account out of SDDM entirely. initialHashedPassword,
    # so passwd on the device sticks. The hash is "password" -- change it.
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

  # nixos-sheng ships drivers only, so the root password and autologin are
  # ours now. Bring-up defaults, NOT safe: the hash is "password" and tty1
  # logs in as root without asking.
  users.users.root.hashedPassword = "$6$e/k7.7lhroPMA6hy$ysO.xH9hAm5y0NCdKQs4AAT0MQFy0kP7F6XpVIryRAN1wNHReXXHx21zdonHiXwKuynriN9UA.OQDhhz67atj/";
  users.mutableUsers = true;

  # Set here, not as a runtime drop-in, which systemd applies first.
  services.getty.autologinUser = "root";
}

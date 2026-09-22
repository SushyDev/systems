{
  lib,
  pkgs,
  setup,
  ...
}:
let
  mkStandardUser = user: {
    home = "/Users/${user}";
    createHome = true;
    isHidden = false;
    shell = pkgs.zsh;
  };
in
{
  # Setup users

  users.knownUsers = setup.managedUsers;

  users.users.sushy = mkStandardUser "sushy" // {
    uid = 501;
  };

  users.users.work = mkStandardUser "work" // {
    uid = 503;
  };

  # Other system settings

  environment.pathsToLink = [ "/share/zsh" ];

  time.timeZone = "Europe/Amsterdam";

  # system.primaryUser = lib.head setup.managedUsers;
  system.stateVersion = 25.11;
  system.startup.chime = false;
  networking.computerName = "quasar";
  networking.hostName = "quasar";
  networking.localHostName = "quasar";
  # networking.nameservers = [
  #   "1.1.1.1"
  #   "8.8.8.8"
  # ];

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;
}

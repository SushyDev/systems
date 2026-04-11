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
  # Setup groups

  users.knownGroups = [ setup.nixGroupName ];

  users.groups."${setup.nixGroupName}" = {
    name = setup.nixGroupName;
    gid = setup.nixGroupId;
    members = setup.managedUsers;
  };

  # Setup users

  users.knownUsers = setup.managedUsers;

  users.users.sushy = mkStandardUser "sushy" // {
    uid = 502;
  };

  users.users.work = mkStandardUser "work" // {
    uid = 501;
  };

  # Setup basic nix conveniences

  system.activationScripts.extraActivation.text = lib.mkAfter ''
    /bin/mkdir -p ${setup.systemFlakePath}
    /usr/sbin/chown -R root:nix ${setup.systemFlakePath}
    /bin/chmod -R g+rwX ${setup.systemFlakePath}
  '';

  environment.shellAliases = {
    darwin-switch = "/usr/bin/sudo ${lib.getExe pkgs.nix} run nix-darwin/master#darwin-rebuild -- switch --flake ${setup.systemFlakePath}";
    darwin-update = "/usr/bin/sudo ${lib.getExe pkgs.nix} flake update --flake ${setup.systemFlakePath}";
  };

  security.sudo.extraConfig = ''
    %nix ALL=(ALL) NOPASSWD: ${lib.getExe pkgs.nix} run nix-darwin/master\#darwin-rebuild -- switch --flake ${setup.systemFlakePath}
    %nix ALL=(ALL) NOPASSWD: ${lib.getExe pkgs.nix} flake update --flake ${setup.systemFlakePath}
  '';

  # Other system settings

  environment.pathsToLink = [ "/share/zsh" ];

  time.timeZone = "Europe/Amsterdam";

  # system.primaryUser = lib.head setup.managedUsers;
  system.stateVersion = 25.11;
  system.startup.chime = false;
  networking.computerName = "quasar";
  networking.hostName = "quasar";
  networking.localHostName = "quasar";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
}

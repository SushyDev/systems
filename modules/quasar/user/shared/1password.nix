{
  lib,
  config,
  systemConfig,
  ...
}:
let
  isOnePasswordGui = pkg: pkg.pname or "" == "1password";
  onePasswordPkg = lib.findFirst isOnePasswordGui (
    lib.findFirst isOnePasswordGui null config.home.packages
  ) systemConfig.environment.systemPackages;
  hasOnePassword = onePasswordPkg != null;
  # Link straight to the package's Nix store path rather than through the
  # "/Applications/Nix Apps" or "~/Applications/Home Manager Apps" indirection,
  # so this doesn't depend on nix-darwin/home-manager's own app-linking step.
  onePasswordAppSource = "${onePasswordPkg}/Applications/1Password.app";
  onePasswordGroupContainer = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password";
in
lib.mkIf hasOnePassword {
  # https://developer.1password.com/docs/ssh/agent/compatibility/#configure-ssh_auth_sock-globally-for-every-client
  launchd.agents."com.1password.SSH_AUTH_SOCK" = {
    enable = builtins.pathExists onePasswordGroupContainer;
    config = {
      Label = "com.1password.SSH_AUTH_SOCK";
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          mkdir -p "$(dirname "$SSH_AUTH_SOCK")"
          /bin/ln -sf "${onePasswordGroupContainer}/t/agent.sock" "$SSH_AUTH_SOCK"
        ''
      ];
      RunAtLoad = true;
      StandardErrorPath = "/tmp/1password-ssh.err";
      StandardOutPath = "/tmp/1password-ssh.out";
    };
  };

  # 1Password expects to live at exactly /Applications/1Password.app (e.g. for
  # browser extension pairing). Force this on every activation so it survives
  # anything else touching /Applications/1Password.app between switches.
  home.activation.link1PasswordApp = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD /bin/ln -sfn "${onePasswordAppSource}" "/Applications/1Password.app"
  '';
}

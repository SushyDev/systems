{
  lib,
  config,
  systemConfig,
  ...
}:
let
  isOnePasswordGui = pkg: pkg.pname or "" == "1password";
  inSystemPackages = lib.any isOnePasswordGui systemConfig.environment.systemPackages;
  inHomePackages = lib.any isOnePasswordGui config.home.packages;
  hasOnePassword = inSystemPackages || inHomePackages;
  onePasswordAppSource =
    if inSystemPackages then
      "/Applications/Nix Apps/1Password.app"
    else
      "${config.home.homeDirectory}/Applications/Home Manager Apps/1Password.app";
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
  # browser extension pairing), but it only gets linked into "/Applications/Nix Apps"
  # (system config) or "~/Applications/Home Manager Apps" (home config).
  home.activation.link1PasswordApp = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD /bin/ln -sfn "${onePasswordAppSource}" "/Applications/1Password.app"
  '';
}

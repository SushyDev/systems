{
  config,
  lib,
  pkgs,
  ...
}:
let
  identityAgentPath = config.dotfiles.ssh.identityAgentPath;
  # ssh_config expands "~", an environment variable does not.
  agentSocket = lib.replaceStrings [ "~" ] [ config.home.homeDirectory ] identityAgentPath;
in
{
  programs.ssh = {
    enable = true;
    settings = {
      "*.local" = {
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
        LogLevel = "ERROR";
      };
    };
  };

  # IdentityAgent only reaches the ssh client; ssh-add and every other agent
  # client reads SSH_AUTH_SOCK. Darwin sets it from launchd instead.
  home.sessionVariables = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && identityAgentPath != "") {
    SSH_AUTH_SOCK = agentSocket;
  };
}

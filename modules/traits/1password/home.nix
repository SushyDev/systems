{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  package = osConfig.programs._1password-gui.package;

  groupContainer = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password";
  agentSocket =
    if isDarwin then "${groupContainer}/t/agent.sock" else "${config.home.homeDirectory}/.1password/agent.sock";

  signer =
    if isDarwin then
      "${package}/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      lib.getExe' package "op-ssh-sign";
in
{
  programs.ssh = {
    settings."*".IdentityAgent = ''"${agentSocket}"'';
    # First, since ssh keeps the first value it sees.
    includes = lib.mkBefore [ "${config.home.homeDirectory}/.ssh/1Password/config" ];
  };

  programs.git.signing = {
    format = "ssh";
    inherit signer;
  };

  # Shell plugins alias each command; completealiases keeps completion working for those aliases.
  programs.zsh.initContent = ''
    if [[ -f "$HOME/.config/op/plugins.sh" ]]; then
      source "$HOME/.config/op/plugins.sh"
      setopt completealiases
    fi
  '';

  home.sessionVariables = lib.mkIf isLinux {
    SSH_AUTH_SOCK = agentSocket;
  };

  # https://developer.1password.com/docs/ssh/agent/compatibility/#configure-ssh_auth_sock-globally-for-every-client
  launchd.agents."com.1password.SSH_AUTH_SOCK" = lib.mkIf isDarwin {
    enable = builtins.pathExists groupContainer;
    config = {
      Label = "com.1password.SSH_AUTH_SOCK";
      ProgramArguments = [
        (lib.getExe pkgs.bash)
        "-c"
        ''
          ${lib.getExe' pkgs.coreutils "mkdir"} -p "$(${lib.getExe' pkgs.coreutils "dirname"} "$SSH_AUTH_SOCK")"
          ${lib.getExe' pkgs.coreutils "ln"} -sf "${agentSocket}" "$SSH_AUTH_SOCK"
        ''
      ];
      RunAtLoad = true;
      StandardErrorPath = "/tmp/1password-ssh.err";
      StandardOutPath = "/tmp/1password-ssh.out";
    };
  };
}

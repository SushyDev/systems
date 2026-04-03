{ ... }:
{
  # https://developer.1password.com/docs/ssh/agent/compatibility/#configure-ssh_auth_sock-globally-for-every-client
  launchd.agents."com.1password.SSH_AUTH_SOCK" = {
    enable = true;
    config = {
      Label = "com.1password.SSH_AUTH_SOCK";
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''/bin/ln -sf "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" "$SSH_AUTH_SOCK"''
      ];
      RunAtLoad = true;
    };
  };
}

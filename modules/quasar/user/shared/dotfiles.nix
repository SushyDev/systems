{ setup, pkgs, lib, ... }:
{
  dotfiles = {
    enable = true;
    systemFlakePath = setup.systemFlakePath;
    git = {
      sshSignPackage = "${lib.getBin pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
    ssh = {
      identityAgentPath = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
    };
  };
}

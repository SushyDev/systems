{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*.local" = {
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          LogLevel = "ERROR";
        };
      };
    };
  };
}

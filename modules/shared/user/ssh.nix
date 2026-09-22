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
}

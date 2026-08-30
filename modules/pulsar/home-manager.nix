{
  inputs,
  setup,
  pkgs,
  ...
}:
{
  home-manager.users.sushy = {
    home.stateVersion = "25.05";

    home.packages = with pkgs; [
      # Add user-specific packages here
    ];

    programs.bash.enable = true;

    programs.git = {
      enable = true;
      settings = {
        safe.directory = setup.systemFlakePath;
      };
    };

    # BuildX Patch until DDEV fixes their buildx plugin detection
    home.file.".docker/cli-plugins/docker-buildx".source =
      "${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx";
  };
}

{
  lib,
  pkgs,
  ...
}:
let
  extensions = [ (pkgs.callPackage ./color-picker { }) ];
in
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    programs.vicinae = {
      enable = true;
      systemd.enable = true;
      inherit extensions;
    };
  })

  # The home-manager module is Linux-only, so mirror what it does by hand. On
  # macOS vicinae ignores XDG and always reads ~/.config and ~/.local/share.
  (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.packages = [ pkgs.vicinae ];

    home.file =
      lib.listToAttrs (
        map (extension: {
          name = ".local/share/vicinae/extensions/${extension.name}";
          value.source = extension;
        }) extensions
      )
      // {
        ".config/vicinae/settings.json" = {
          # Replaces the stub vicinae writes on first launch.
          force = true;
          text = builtins.toJSON {
            "$schema" = "https://vicinae.com/schemas/config.json";
            # Qt swaps the modifiers on macOS: "control" is ⌘.
            global_shortcuts.toggle = "control+space";
          };
        };
      };

    # Started by launchd rather than vicinae's own SMAppService login item, which
    # would pin whichever store path happened to register it.
    launchd.agents.vicinae = {
      enable = true;
      config = {
        ProgramArguments = [
          (lib.getExe pkgs.vicinae)
          "server"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
      };
    };
  })
]

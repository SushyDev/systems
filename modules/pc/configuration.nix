{
  setup,
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  traits = import ../traits;
in
{
  imports = [
    ./packages.nix
    ./programs.nix
    ./security.nix
    ./services.nix
    ./k3s.nix

    ./system/default.nix
    ../shared/fonts.nix
    # ./hardening.nix
  ]
  ++ (with traits; [
    use1Password
    useKde
    useOxidation
    usePasswordlessSudo
  ]);

  i18n.defaultLocale = "en_US.UTF-8";
  console.earlySetup = true;
  time.timeZone = "Europe/Amsterdam";
  system.stateVersion = "25.05";

  environment.shellAliases = {
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };
}

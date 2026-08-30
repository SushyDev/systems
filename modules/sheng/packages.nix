{ nixpkgs, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.curl
    pkgs.wget
    pkgs.git
    # busybox is for `devmem`.
    pkgs.busybox

    pkgs.ghostty
    pkgs.mkcert
    pkgs.opencode
    pkgs.vivaldi
    pkgs.xdg-utils

    pkgs.snapshot
    pkgs.kdePackages.kamoso

    # Provides libcamerify plus v4l2-compat.so, the shim that presents
    # libcamera cameras to V4L2-only applications:
    #   LD_PRELOAD=.../libexec/libcamera/v4l2-compat.so <app>
    pkgs.libcamera

    pkgs.claude-code
    pkgs.github-cli
  ];

  fonts.packages = [
    pkgs.fira-code
  ];
}

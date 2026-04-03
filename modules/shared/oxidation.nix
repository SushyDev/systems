{ self, pkgs, ... }:
{
  environment.shellAliases = {
    # find = "fd --hidden --follow --exclude .git";
    # grep = "rg --color=always";
    cat = "bat --paging=never --style=plain";
    ls = "eza";
  };

  environment.systemPackages = [
    pkgs.ripgrep
    pkgs.eza
    pkgs.bat
    pkgs.fd
  ];
}

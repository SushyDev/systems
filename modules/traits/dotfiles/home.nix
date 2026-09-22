{ inputs, ... }:
{
  imports = [ inputs.dotfiles.homeManagerModules.default ];

  dotfiles.enable = true;
}

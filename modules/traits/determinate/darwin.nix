{ inputs, ... }:
{
  imports = [ inputs.determinate.darwinModules.default ];

  determinateNix.enable = true;
}

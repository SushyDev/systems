{ trait, ... }:
{
  programs.git.settings.safe.directory = trait.parameters.path;
}

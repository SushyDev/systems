{ setup, ... }:
{
  dotfiles = {
    enable = true;
    systemFlakePath = setup.systemFlakePath;
  };
}

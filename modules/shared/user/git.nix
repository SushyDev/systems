let
  name = "SushyDev";
  email = "mail@sushy.dev";
  key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImyhNk+raDf5TXHFWOyWIKw8IQapkhwJ5e+iLQydSFR";
in
{
  home.file.".config/git/sushy".text = ''
    [user]
      name = ${name}
      email = ${email}
      signingkey = ${key}
  '';

  programs.git = {
    settings.user.name = name;
    settings.user.email = email;
    signing.key = key;
  };
}

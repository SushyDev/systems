{
  defaults = class: {
    group = "nix";
    path = if class == "darwin" then "/etc/nix-darwin" else "/etc/nixos";
  };

  example.gid = 999;
}

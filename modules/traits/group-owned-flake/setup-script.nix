{
  lib,
  pkgs,
  path,
  group,
}:
let
  coreutil = lib.getExe' pkgs.coreutils;
in
''
  ${coreutil "mkdir"} -p ${path}
  ${coreutil "chown"} -R root:${group} ${path}
  ${coreutil "chmod"} -R g+rwX,o+rX ${path}
''

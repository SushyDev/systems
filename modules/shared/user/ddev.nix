{
  lib,
  pkgs,
  config,
  systemConfig ? null,
  ...
}:
let
  hasDdev = lib.any (pkg: pkg.pname or "" == "ddev") (
    config.home.packages ++ systemConfig.environment.systemPackages
  );
in
lib.mkIf hasDdev {
  home.activation.ddevCreateDirs = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    mkdir -p ${config.home.homeDirectory}/.ddev/commands/web/autocomplete
  '';

  home.activation.ddevCopyAutocompletScripts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cp -f ${./ddev/artisan.sh} ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/artisan
    chmod 644 ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/artisan
    chmod +x ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/artisan
    cp -f ${./ddev/magento.sh} ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/magento
    chmod 644 ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/magento
    chmod +x ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/magento
  '';

  home.activation.ddevFixCommands = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v ddev &>/dev/null; then
      $DRY_RUN_CMD ddev utility fix-commands || true
    fi
  '';
}

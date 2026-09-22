{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.packages = [ pkgs.ddev ];

  home.activation.ddevCreateDirs = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    mkdir -p ${config.home.homeDirectory}/.ddev/commands/web/autocomplete
  '';

  home.activation.ddevCopyAutocompletScripts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cp -f ${./artisan.sh} ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/artisan
    chmod 644 ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/artisan
    chmod +x ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/artisan
    cp -f ${./magento.sh} ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/magento
    chmod 644 ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/magento
    chmod +x ${config.home.homeDirectory}/.ddev/commands/web/autocomplete/magento
  '';

  home.activation.ddevFixCommands = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v ddev &>/dev/null; then
      $DRY_RUN_CMD ddev utility fix-commands || true
    fi
  '';
}

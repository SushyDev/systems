{ lib }:
let
  systemClasses = [
    "nixos"
    "darwin"
  ];

  hasFile = directory: file: builtins.pathExists (directory + "/${file}");

  supports =
    directory: class:
    if class == "homeManager" then
      hasFile directory "home.nix"
    else
      lib.elem class systemClasses
      && (
        hasFile directory "common.nix" || hasFile directory "${class}.nix" || hasFile directory "home.nix"
      );

  capabilitiesOf = options: {
    homeManager = options ? home-manager;
    determinateNix = options ? determinateNix;
    systemd = options ? systemd;
  };

  # Files that take a `trait` argument get it injected; everything else is imported as-is.
  inject =
    trait: file:
    let
      module = import file;
      moduleArguments = lib.functionArgs module;
    in
    if lib.isFunction module && moduleArguments ? trait then
      {
        _file = toString file;
        imports = [
          (lib.setFunctionArgs (arguments: module (arguments // { inherit trait; })) (
            removeAttrs moduleArguments [ "trait" ]
          ))
        ];
      }
    else
      file;

  mkTrait =
    {
      name,
      directory,
      defaults ? { },
      parameters ? { },
    }:
    { _class, options, ... }:
    let
      isSystem = lib.elem _class systemClasses;
      resolvedParameters = (if lib.isFunction defaults then defaults _class else defaults) // parameters;
      trait = {
        inherit name;
        class = _class;
        parameters = resolvedParameters;
        capabilities = capabilitiesOf options;
      };
      load = file: lib.optional (hasFile directory file) (inject trait (directory + "/${file}"));
    in
    {
      key = "trait:${name}";
      _file = toString directory;

      imports =
        if !supports directory _class then
          throw "trait ${name} does not support ${toString _class}"
        else if isSystem then
          load "common.nix" ++ load "${_class}.nix"
        else
          load "home.nix";

      config = lib.optionalAttrs (isSystem && hasFile directory "home.nix" && options ? home-manager) {
        home-manager.sharedModules = [
          (mkTrait {
            inherit name directory;
            parameters = resolvedParameters;
          })
        ];
      };
    };

  definitionOf =
    name: directory:
    let
      settings = if hasFile directory "parameters.nix" then import (directory + "/parameters.nix") else null;
    in
    {
      inherit name directory;
      parameterized = settings != null;
      defaults = if settings == null then { } else settings.defaults or { };
      example = if settings == null then { } else settings.example or { };
    };

  mkTraits =
    directories:
    let
      definitions = lib.mapAttrs definitionOf directories;
    in
    lib.mapAttrs (
      name: definition:
      let
        base = { inherit (definition) name directory defaults; };
      in
      if definition.parameterized then parameters: mkTrait (base // { inherit parameters; }) else mkTrait base
    ) definitions
    // {
      __definitions = definitions;
    };

  classesOf =
    definition: lib.filter (supports definition.directory) (systemClasses ++ [ "homeManager" ]);

  traitNamesIn =
    graph:
    lib.concatMap (
      node:
      let
        traitName = builtins.match "trait:([^:]+)" node.key;
      in
      lib.optional (!node.disabled && traitName != null) (lib.head traitName) ++ traitNamesIn node.imports
    ) graph;

  userConfigurationsOf =
    configuration:
    lib.mapAttrs (_user: meta: meta.configuration) (
      let
        attempt = builtins.tryEval configuration.options.home-manager.users.valueMeta.attrs;
      in
      if attempt.success then attempt.value else { }
    );
in
{
  inherit
    capabilitiesOf
    classesOf
    mkTrait
    mkTraits
    ;

  mkChecks =
    {
      traits,
      pkgs,
      specialArgs ? { },
      nixos ? null,
      darwin ? null,
    }:
    let
      homeManagerBase = {
        home-manager = {
          useGlobalPkgs = true;
          extraSpecialArgs = specialArgs;
          users.check.home.stateVersion = "25.05";
        };
      };

      platforms = lib.filterAttrs (_class: platform: platform != null) {
        nixos = lib.mapNullable (platform: {
          inherit (platform) evaluate;
          base = [
            platform.homeManager
            homeManagerBase
            {
              boot.loader.grub.enable = false;
              fileSystems."/" = {
                device = "none";
                fsType = "tmpfs";
              };
              nixpkgs.config.allowUnfree = true;
              nixpkgs.hostPlatform = platform.hostPlatform;
              system.stateVersion = "25.11";
              users.users.check.isNormalUser = true;
            }
          ];
        }) nixos;

        darwin = lib.mapNullable (platform: {
          inherit (platform) evaluate;
          base = [
            platform.homeManager
            homeManagerBase
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.hostPlatform = platform.hostPlatform;
              system.stateVersion = 6;
              users.users.check.home = "/Users/check";
            }
          ];
        }) darwin;
      };

      moduleOf =
        definition:
        if definition.parameterized then traits.${definition.name} definition.example else traits.${definition.name};

      check =
        definition: class: platform: placement:
        let
          system = platform.evaluate {
            inherit specialArgs;
            modules = platform.base ++ [ placement ];
          };
          name = "trait-${definition.name}-${class}";
        in
        lib.nameValuePair name (
          pkgs.writeText name (
            builtins.unsafeDiscardStringContext system.config.system.build.toplevel.drvPath
          )
        );

      checksFor =
        definition:
        lib.concatMap (
          class:
          if class == "homeManager" then
            lib.optional (platforms ? nixos) (
              check definition class platforms.nixos {
                home-manager.users.check.imports = [ (moduleOf definition) ];
              }
            )
          else
            lib.optional (platforms ? ${class}) (check definition class platforms.${class} (moduleOf definition))
        ) (classesOf definition);
    in
    lib.listToAttrs (lib.concatMap checksFor (lib.attrValues traits.__definitions));

  mkTraitsApp =
    {
      pkgs,
      configurations,
    }:
    let
      columns = lib.concatLists (
        lib.mapAttrsToList (
          host: configuration:
          [
            {
              name = host;
              traits = traitNamesIn configuration.graph;
            }
          ]
          ++ lib.mapAttrsToList (user: userConfiguration: {
            name = "${host}/${user}";
            traits = traitNamesIn userConfiguration.graph;
          }) (userConfigurationsOf configuration)
        ) configurations
      );

      traitNames = lib.unique (lib.sort lib.lessThan (lib.concatMap (column: column.traits) columns));
      nameWidth = lib.foldl' lib.max 0 (map lib.stringLength traitNames);

      mark = "●";
      visualLength = text: if text == mark then 1 else lib.stringLength text;
      padTo = width: text: text + lib.concatStrings (lib.replicate (width - visualLength text) " ");
      cellIn = column: padTo (lib.stringLength column.name + 2);

      header = padTo (nameWidth + 2) "" + lib.concatMapStrings (column: cellIn column column.name) columns;
      rowFor =
        traitName:
        padTo (nameWidth + 2) traitName
        + lib.concatMapStrings (
          column: cellIn column (if lib.elem traitName column.traits then mark else "")
        ) columns;

      table = lib.concatStringsSep "\n" ([ header ] ++ map rowFor traitNames) + "\n";
    in
    {
      type = "app";
      program = lib.getExe (
        pkgs.writeShellApplication {
          name = "traits";
          text = ''
            cat ${pkgs.writeText "traits-table" table}
          '';
        }
      );
    };
}

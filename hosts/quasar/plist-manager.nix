{
  programs.nix-plist-manager = {
    enable = true;

    options = {
      applications = {
        systemSettings = {
          sound = {
            soundEffects = {
              playSoundOnStartup = false;
            };
          };
          network.firewall = {
            firewall = true;
            options = {
              automaticallyAllowBuiltInSoftwareToReceiveIncomingConnections = true;
              automaticallyAllowDownloadedSignedSoftwareToReceiveIncomingConnections = true;
              blockAllIncomingConnections = false;
              enableStealthMode = false;
            };
          };
          privacyAndSecurity = {
            analyticsAndImprovements = {
              shareMacAnalytics = false;
              shareWithAppDevelopers = false;
            };
            advanced = {
              logOutAutomaticallyAfterInactivity = 0;
              requireAnAdministratorPasswordToAccessSystemWideSettings = false;
            };
          };
          wiFi = {
            askToJoinHotspots = "Ask To Join";
            askToJoinNetworks = "Notify";
            requireAdministratorAuthorizationTo = {
              changeNetworks = false;
              turnWiFiOnOrOff = false;
            };
            showLegacyNetworksAndOptions = false;
          };
          lockScreen = {
            loginWindowShows = "List of users";
            showPasswordHints = false;
            showTheSleepRestartAndShutDownButtons = true;
            turnDisplayOffOnBatteryWhenInactive = "For 2 minutes";
            turnDisplayOffOnPowerAdapterWhenInactive = "For 1 hour";
          };
          battery = {
            energyMode = {
              onBattery = "Automatic";
              onPowerAdapter = "High Power";
            };
            options = {
              preventAutomaticSleepingOnPowerAdapterWhenTheDisplayIsOff = false;
              slightlyDimTheDisplayOnBattery = false;
              wakeForNetworkAccess = "Only on Power Adapter";
            };
          };
          general = {
            dateAndTime = {
              setTimeAndDateAutomatically = true;
              setTimeZoneAutomaticallyUsingYourCurrentLocation = true;
              source = "time.apple.com";
            };
            sharing = {
              contentCaching = false;
              contentCachingOptions = {
                shareInternetConnection = false;
              };
              fileSharing = false;
              fileSharingOptions = {
                sharedFolders = {
                  "/Users/sushy/Public" = "Sushy’s Public Folder";
                };
              };
              printerSharing = false;
              remoteApplicationScripting = false;
              remoteApplicationScriptingOptions = {
                allowAccessFor = "Only these users";
              };
              remoteManagement = false;
              remoteManagementOptions = {
                allowAccessFor = "All users";
              };
              screenSharing = false;
              screenSharingOptions = {
                allowAccessFor = "Only these users";
              };
            };
            softwareUpdate = {
              automaticallyDownloadNewUpdatesWhenAvailable = true;
              automaticallyInstallApplicationUpdatesFromTheAppStore = true;
              automaticallyInstallMacOSUpdates = true;
              automaticallyInstallSystemDataFilesAndSecurityUpdates = true;
            };
          };
        };
      };
    };
  };
}

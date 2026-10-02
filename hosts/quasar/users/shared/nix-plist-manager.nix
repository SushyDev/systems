{ lib, ... }:
let
  # macOS ignores a symbolic hotkey stored as only { enabled = false; }, which is all
  # nix-plist-manager writes for `false`, so the shortcut keeps working. Disabled
  # entries only take when they carry their keys, as System Settings writes them.
  disabledHotKey =
    id: parameters:
    let
      integers = lib.concatMapStrings (p: "<integer>${toString p}</integer>") parameters;
    in
    "${toString id} '<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array>${integers}</array><key>type</key><string>standard</string></dict></dict>'";
in
{
  home.activation.disableSymbolicHotKeys = lib.hm.dag.entryAfter [ "nix-plist-manager" ] ''
    run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add \
      ${disabledHotKey 64 [ 32 49 1048576 ]} \
      ${disabledHotKey 263 [ 32 49 1179648 ]}
    run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  programs.nix-plist-manager = {
    enable = true;

    options = {
      applications = {
        journal = {
          addEntryTitle = "Always";
          alwaysUseMomentDate = false;
          getWritingPrompts = true;
        };
        voiceMemos = {
          audioQuality = "Lossy";
          clearDeleted = "After 30 Days";
          locationBasedNaming = true;
        };
        finder = {
          menuBar = {
            view = {
              showPathBar = true;
              showSidebar = true;
              showStatusBar = true;
              showTabBar = true;
            };
          };
          settings = {
            advanced = {
              keepFoldersOnTop = {
                inWindowsWhenSortingByName = true;
                onDesktop = true;
              };
              removeItemsFromTheTrashAfter30Days = true;
              showAllFilenameExtensions = true;
              showWarningBeforeChangingAnExtension = true;
              showWarningBeforeEmptyingTheTrash = true;
              showWarningBeforeRemovingFromiCloudDrive = true;
              whenPerformingASearch = "Search the Current Folder";
            };
            general = {
              showTheseItemsOnTheDesktop = {
                cdsDvdsAndiPods = false;
                connectedServers = false;
                externalDisks = false;
                hardDisks = false;
              };
            };
            sidebar = {
              recentTags = false;
            };
          };
        };
        systemSettings = {
          printersAndScanners.defaultPaperSize = "A4";
          privacyAndSecurity.appleAdvertising.personalizedAds = false;
          keyboard = {
            delayUntilRepeat = 25;
            keyRepeatRate = 2;
            keyboardNavigation = false;
            pressGlobeKeyTo = "Change Input Source";
            textInput = {
              addPeriodWithDoubleSpace = true;
              automaticallySwitchToADocumentsInputSource = false;
              capitalizeWordsAutomatically = true;
              correctSpellingAutomatically = true;
              inputSources = [ "com.apple.keylayout.US" "com.apple.keylayout.ABC" ];
              showInlinePredictiveText = true;
              showSuggestedReplies = true;
              useSmartQuotesAndDashes = true;
            };
            useF1F2EtcKeysAsStandardFunctionKeys = true;
            keyboardShortcuts = {
              accessibility = {
                decreaseContrast = false;
                increaseContrast = false;
                invertColors = false;
              };
              inputSources = {
                selectNextSourceInInputMenu = false;
                selectThePreviousInputSource = false;
              };
              missionControl = {
                gameOverlay = "⌘Escape";
                moveLeftASpace = true;
                moveRightASpace = true;
              };
              screenshots = {
                copyPictureOfSelectedAreaToTheClipboard = "⇧⌘S";
                # ⌘⇧Space, the Siri keyboard shortcut; see disableSymbolicHotKeys
                askSiriAboutActiveWindow = false;
              };
              spotlight = {
                # ⌘Space; see disableSymbolicHotKeys
                showSpotlightSearch = false;
              };
            };
          };
          trackpad = {
            moreGestures = {
              appExpose = "Off";
              missionControl = "Swipe Up with Three Fingers";
              notificationCenter = true;
              showDesktop = false;
              swipeBetweenFullScreenApplications = "Swipe Left or Right with Three Fingers";
              swipeBetweenPages = "Scroll Left or Right with Two Fingers";
            };
            pointAndClick = {
              click = "Medium";
              forceClickAndHapticFeedback = true;
              lookUpAndDataDetectors = "Force Click with One Finger";
              secondaryClick = "Click or Tap with Two Fingers";
              tapToClick = true;
            };
            scrollAndZoom = {
              naturalScrolling = true;
              rotate = true;
              smartZoom = true;
              zoomInOrOut = true;
            };
          };
          # nix run github:sushydev/nix-plist-manager#capture -- applications.systemSettings.<desktopAndDock.dock.contents|menuBar.layout|wallpaper.snapshot> <directory>
          desktopAndDock.dock.contents = ./dock;
          menuBar.layout = ./menu-bar;
          wallpaper.photo = ./wallpaper.png;
          wallpaper.startScreenSaver = "After 20 minutes";

          accessibility = {
            audio.backgroundSound = ./accessibility/background-sound;
            readAndSpeak.voices = ./accessibility/voices;
            liveSpeech.voices = ./accessibility/live-speech-voices;

            audio = {
              backgroundSounds = false;
              backgroundSoundsOptions = {
                timer = false;
              };
              flashTheScreenWhenAnAlertSoundOccurs = false;
              playStereoAudioAsMono = false;
              turnOffBackgroundSoundsWhenYourMacIsNotInUse = false;
            };
            audioDescriptions = {
              playAudioDescriptionsWhenAvailable = false;
            };
            display = {
              colorFilters = false;
              differentiateWithoutColor = false;
              dimFlashingLights = false;
              filterType = "Grayscale";
              increaseContrast = false;
              invertColors = false;
              menuBarSize = "Default";
              preferHorizontalText = false;
              reduceTransparency = false;
              shakeMousePointerToLocate = true;
              showBorders = false;
              showWindowTitleIcons = false;
              textSize = {
                preferredReadingSize = "DEFAULT";
              };
            };
            hoverText = {
              hoverColor = false;
              hoverText = false;
              hoverTyping = false;
              hoverTypingOptions = {
                backgroundColor = "Default";
                borderColor = "Default";
                elementHighlightColor = "Default";
                insertionPointColor = "Default";
                textColor = "Default";
                textEntryLocation = "Custom";
                textSize = 60;
              };
              options = {
                activationModifier = "⌘ Command";
                backgroundColor = "Default";
                borderColor = "Default";
                elementHighlightColor = "Default";
                textColor = "Default";
                textSize = 60;
                triplePressModifierToSetActivationLock = false;
              };
            };
            keyboard = {
              accessibilityKeyboardOptions = {
                appearance = "Dark";
                fadePanelAfterInactivity = false;
                playSoundsForKeysAndDwellActions = true;
              };
              fullKeyboardAccessOptions = {
                autoHide = true;
                color = "Default";
                highContrast = false;
                increaseSize = false;
              };
              slowKeys = false;
              slowKeysOptions = {
                acceptanceDelay = 250;
              };
              stickyKeys = false;
              stickyKeysOptions = {
                beepWhenAModifierKeyIsSet = true;
                displayPressedKeysOnScreen = true;
                pressTheShiftKeyFiveTimesToToggleStickyKeys = false;
                screenAreaForDisplay = "Top Left";
              };
            };
            liveCaptions = {
              language = "en-US";
              liveCaptionsInFaceTime = false;
            };
            liveSpeech = {
              liveSpeech = false;
            };
            motion = {
              autoPlayAnimatedImages = true;
              preferNonBlinkingCursor = false;
              reduceMotion = false;
              vehicleMotionCues = false;
            };
            pointerControl = {
              alternatePointerActionsOptions = {
                playSounds = false;
                showActionsVisually = false;
              };
              headPointerOptions = {
                distanceToEdge = 0;
                pointerMoves = "Relative to head movement";
                pointerSpeed = 0.5;
                useASwitchOrFacialExpressionToPauseOrResume = false;
                useASwitchOrFacialExpressionToRecalibrate = false;
              };
              ignoreBuiltInTrackpadWhenMouseOrWirelessTrackpadIsPresent = false;
              mouseKeys = false;
              mouseKeysOptions = {
                ignoreBuiltInTrackpadWhenMouseKeysIsOn = false;
                pressTheOptionKeyFiveTimesToToggleMouseKeys = false;
              };
              springLoading = true;
              springLoadingSpeed = 0.5;
              trackpadOptions = {
                useInertiaWhenScrolling = true;
                dragging = "Off";
                useTrackpadForScrolling = true;
              };
            };
            readAndSpeak = {
              accessibilityReader.shortcuts = ./accessibility/reader-shortcuts;
              accessibilityReader = {
                automaticallyApplyFormatting = true;
                autoplay = false;
                enable = false;
              };
              detectLanguages = true;
              pronunciations = false;
              speakAnnouncements = false;
              speakAnnouncementsOptions = {
                phrase = "Alert!";
              };
              speakItemUnderThePointer = false;
              speakItemUnderThePointerOptions = {
                speak = "Always";
                speechVerbosity = "Low";
              };
              speakSelection = false;
              speakSelectionOptions = {
                keyboardShortcut = 2101;
                highlightContent = "Words";
                sentenceColor = "Default";
                sentenceStyle = "Background color";
                showController = "Automatically";
                wordColor = "Default";
              };
              speakTypingFeedback = false;
              systemSpeechLanguage = "Use System Language";
              typingFeedback = {
                characters = true;
                modifierKeys = false;
                selectionChanges = false;
                words = true;
              };
            };
            rtt = {
              sendImmediately = true;
            };
            shortcut = {
              features = {
                accessibilityKeyboard = true;
                accessibilityReader = true;
                backgroundSounds = true;
                colorFilters = true;
                fullKeyboardAccess = true;
                headPointer = true;
                hoverText = true;
                hoverTyping = true;
                increaseContrast = true;
                invertDisplayColor = true;
                liveCaptions = true;
                liveSpeech = true;
                mouseKeys = true;
                reduceTransparency = true;
                showBorders = true;
                slowKeys = true;
                stickyKeys = true;
                vehicleMotionCues = true;
                voiceControl = true;
                voiceOver = true;
                zoom = true;
              };
              speech = true;
            };
            siri = {
              listenForAtypicalSpeech = false;
            };
            subtitlesAndCaptioning = {
              applyAcrossApps = false;
              preferClosedCaptionsAndSdh = false;
              showAutomaticallyWhenLanguagesDoNotMatch = true;
              showOnSkipBack = true;
              showWhenMuted = true;
            };
            switchControl = {
              autoScanningIntervalInInterface = 0.5;
              autoScanningIntervalInPanels = 0.5;
              durationOfInactivity = 15;
              glidingAndRotatingCursorSpeed = 5;
              holdBeforePerformDuration = 0;
              holdBeforeRepeatDuration = 3;
              ignoreSwitchRepeats = 0;
              pauseOnFirstItem = 0;
            };
            zoom = {
              useKeyboardShortcutsToZoom = false;
              useScrollGestureWithModifierKeysToZoom = false;
              useTrackpadGestureToZoom = false;
              zoomStyle = "Full Screen";
            };
            zoomAdvanced = {
              showZoomedImageWhileScreenSharing = false;
            };
          };
          appearance = {
            accentColor = "Graphite";
            allowWallpaperTintingInWindows = false;
            appearance = "Dark";
            clickInTheScrollBarTo = "Jump to the next page";
            iconAndWidgetStyle = "ClearAutomatic";
            iconWidgetAndFolderColor = "Graphite";
            liquidGlass = 0.5;
            showScrollBars = "Automatically based on mouse or trackpad";
            sidebarIconSize = "Medium";
            textHighlightColor = "Blue";
          };
          appleIntelligenceAndSiri = {
            appleIntelligence = true;
            automaticVisualLookUp = false;
            chatGpt = {
              useExtension = false;
            };
            siri = {
              enable = true;
              responses = "Spoken Response";
            };
          };
          desktopAndDock = {
            desktopAndStageManager = {
              clickWallpaperToRevealDesktop = "Only in Stage Manager";
              showItems = {
                inStageManager = false;
                onDesktop = false;
              };
              showRecentAppsInStageManager = false;
              showWindowsFromAnApplication = "One at a Time";
              stageManager = false;
            };
            dock = {
              animateOpeningApplications = true;
              automaticallyHideAndShowTheDock = {
                delay = 0;
                duration = 0;
                enabled = true;
              };
              dockPositionOnScreen = "Bottom";
              magnification = {
                enabled = false;
              };
              minimizeWindowsIntoApplicationIcon = true;
              minimizedWindowAnimation = "Genie Effect";
              showIndicatorsForOpenApplications = true;
              showSuggestedAndRecentAppsInDock = false;
              size = 48;
              windowTitleBarDoubleClickAction = "Fill";
            };
            hotCorners = {
              bottomLeft = {
                action = "-";
              };
              bottomRight = {
                action = "-";
              };
              topLeft = {
                action = "-";
              };
              topRight = {
                action = "-";
              };
            };
            missionControl = {
              automaticallyRearrangeSpacesBasedOnMostRecentUse = false;
              displaysHaveSeparateSpaces = true;
              dragWindowsToTopOfScreenToEnterMissionControl = false;
              groupWindowsByApplication = false;
              shortcuts = {
                applicationWindows = "⌃↓";
                missionControl = "⌃↑";
                showDesktop = "fn F11";
              };
              whenSwitchingToAnApplicationSwitchToAspaceWithOpenWindowsForTheApplication = false;
            };
            widgets = {
              dimWidgetsOnDesktop = "Automatically";
              showWidgets = {
                inStageManager = false;
                onDesktop = false;
              };
            };
            windows = {
              askToKeepChangesWhenClosingDocuments = false;
              closeWindowsWhenQuittingAnApplication = false;
              dragWindowsToLeftOrRightEdgeOfScreenToTile = true;
              dragWindowsToMenuBarToFillScreen = true;
              holdOptionKeyWhileDraggingWindowsToTile = false;
              preferTabsWhenOpeningDocuments = "Never";
              tiledWindowsHaveMargins = false;
            };
          };
          displays = {
            nightShift = {
              colorTemperature = 1;
              schedule = "Off";
            };
            trueTone = false;
            showResolutionsAsList = false;
            universalControl = {
              allowPointerAndKeyboardToMoveBetweenNearbyDevices = true;
              pushThroughTheEdgeOfADisplayToConnect = true;
            };
            whenConnectedToTv = "Ask What to Show";
          };
          focus = {
            shareAcrossDevices = false;
          };
          general = {
            airDropAndContinuity = {
              airDrop = "Contacts Only";
              airPlayReceiver = true;
              allowHandoffBetweenThisMacAndYourIcloudDevices = true;
              iPhoneWidgets = false;
            };
            autoFillAndPasswords = {
              autoFillFromPasswords = true;
              autoFillPasswordsAndPasskeys = true;
              deleteVerificationCodesAfterUse = true;
            };
            dateAndTime = {
              "24HourTime" = true;
            };
            languageAndRegion = {
              dateFormat = "19/08/2026";
              firstDayOfWeek = "Monday";
              liveText = true;
              measurementSystem = "Metric";
              numberFormat = "1.234.567,89";
              preferredLanguages = [ "en-US" "nl-NL" ];
              region = "en_US@rg=nlzzzz";
              temperature = "Celsius (°C)";
            };
            sharing = {
              bluetoothSharing = {
                enable = false;
                whenOtherDevicesBrowse = "Accept and Save";
                whenReceivingItems = "Accept and Save";
              };
              mediaSharing = {
                shareMediaWithGuests = false;
              };
            };
          };
          menuBar = {
            airdrop = false;
            autoHideAndShowTheMenuBar = "Always";
            battery = true;
            batteryOptions = {
              showEnergyMode = "Always";
              showPercentage = true;
            };
            bluetooth = false;
            clock = {
              announceTheTime = {
                enable = false;
                interval = "On the hour";
              };
              showAmPm = true;
              displayTheTimeWithSeconds = false;
              flashTheTimeSeparators = false;
              showDate = true;
              showTheDayOfTheWeek = true;
              style = "Digital";
            };
            display = "Don't Show";
            fastUserSwitching = false;
            focusModes = "Show When Active";
            keyboardBrightness = false;
            nowPlaying = "Show When Active";
            recentDocumentsApplicationsAndServers = "10";
            screenMirroring = "Show When Active";
            showMenuBarBackground = false;
            showSuggestionsInControlGallery = true;
            siri = false;
            sound = "Don't Show";
            textInput = false;
            timeMachine = false;
            timer = "Show When Active";
            wifi = false;
          };
          notifications = {
            allowNotifications = {
              whenMirroringOrSharingTheDisplay = "Notifications Off";
              whenTheDisplayIsSleeping = false;
              whenTheScreenIsLocked = true;
            };
            applications = ./notifications;
            notificationCenter = {
              showPreviews = "When Unlocked";
              summarizeNotifications = false;
            };
          };
          sound = {
            soundEffects = {
              alertSound = "Sonar";
              alertVolume = 0.5;
              playFeedbackWhenVolumeIsChanged = false;
              playUserInterfaceSoundEffects = false;
            };
          };
          spotlight = {
            clipboardHistoryIsAvailableInSpotlight = "7 days";
            helpAppleImproveSearch = false;
            resultsFromClipboard = true;
            searchResults = {
              appStore = true;
              apps = true;
              books = true;
              calculator = true;
              calendar = true;
              contacts = true;
              dictionary = true;
              files = true;
              folders = true;
              games = true;
              iPhoneApps = true;
              mail = true;
              menuItems = true;
              messages = true;
              music = true;
              notes = true;
              phone = true;
              photos = true;
              podcasts = true;
              reminders = true;
              safari = true;
              shortcuts = true;
              systemSettings = true;
              tips = true;
              voiceMemos = true;
            };
            showRelatedContent = false;
          };
        };
      };
    };
  };
}

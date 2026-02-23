{ ... }: 
{
	programs.nix-plist-manager = {
		enable = true;

		options = {
			applications = {
				systemSettings = {
					controlCenter = {
						wifi = false;
						bluetooth = false;
						airdrop = false;
						focusModes = "never";
						stageManager = false;
						screenMirroring = "active";
						display = "never";
						sound = "never";
						nowPlaying = "never";
						accessibilityShortcuts = {
							showInMenuBar = false;
							showInControlCenter = false;
						};
						battery = {
							showInMenuBar = true;
							showInControlCenter = false;
						};
						batteryShowPercentage = true;
						musicRecognition = {
							showInMenuBar = false;
							showInControlCenter = false;
						};
						hearing = {
							showInMenuBar = false;
							showInControlCenter = false;
						};
						fastUserSwitching = {
							showInMenuBar = false;
							showInControlCenter = true;
						};
						keyboardBrightness = {
							showInMenuBar = false;
							showInControlCenter = false;
						};
						# menuBarOnly = {
						# 	spotlight = false;
						# 	siri = false;
						# };
						# automaticallyHideAndShowTheMenuBar = "Always";
					};

					appearance = {
						appearance = "Dark";
						accentColor = "Graphite";
						sidebarIconSize = "Medium";
						allowWallpaperTintingInWindows = false;
						showScrollBars = "Automatically based on mouse or trackpad";
						clickInTheScrollBarTo = "Jump to the next page";
					};
					desktopAndDock = {
						dock = {
							size = 48;
							magnification = {
								enabled = false;
							};
							positionOnScreen = "Bottom";
							minimizeWindowsUsing = "Genie Effect";
							doubleClickAWindowsTitleBarTo = "Fill";
							minimizeWindowsIntoApplicationIcon = true;
							automaticallyHideAndShowTheDock = {
								enabled = true;
								delay = 0.0;
								duration = 0.0;
							};
							animateOpeningApplications = true;
							showIndicatorsForOpenApplications = true;
							showSuggestedAndRecentAppsInDock = false;
						};
						desktopAndStageManager = {
							showItems = {
								onDesktop = false;
								inStageManager = false;
							};
							clickWallpaperToRevealDesktop = "Only in Stage Manager";
							stageManager = false;
							showRecentAppsInStageManager = false;
							showWindowsFromAnApplication = "One at a Time";
						};
						widgets = {
							showWidgets = {
								onDesktop = false;
								inStageManager = false;
							};
							widgetStyle = "Automatic";
							useIphoneWidgets = false;
						};
						windows = {
							preferTabsWhenOpeningDocuments = "Never";
							askToKeepChangesWhenClosingDocuments = false;
							closeWindowsWhenQuittingAnApplication = false;
							dragWindowsToScreenEdgesToTile = false;
							dragWindowsToMenuBarToFillScreen = false;
							holdOptionKeyWhileDraggingWindowsToTile = false;
							tiledWindowsHaveMargin = false;
						};
						missionControl = {
							automaticallyRearrangeSpacesBasedOnMostRecentUse = false;
							whenSwitchingToAnApplicationSwitchToAspaceWithOpenWindowsForTheApplication = false;
							groupWindowsByApplication = false;
							displaysHaveSeparateSpaces = true;
							dragWindowsToTopOfScreenToEnterMissionControl = false;
						};
						hotCorners = {
							topLeft = "-";
							topRight = "-";
							bottomLeft = "-";
							bottomRight = "-";
						};
					};
					spotlight = {
						helpAppleImproveSearch = false;
					};
					notifications = {
						notificationCenter = {
							showPreviews = "When Unlocked";
							summarizeNotifications = true;
						};
					};
					sound = {
						soundEffects = {
							alertSound = "Sonar";
							alertVolume = 0.5;
							playUserInterfaceSoundEffects = false;
							playFeedbackWhenVolumeIsChanged = false;
						};
					};
					focus = {
						shareAcrossDevices = false;
					};
				};
				finder = {
					settings = {
						general = {
							showTheseItemsOnTheDesktop = {
								hardDisks = false;
								externalDisks = false;
								cdsDvdsAndiPods = false;
								connectedServers = false;
							};
						};
						sidebar = {
							recentTags = false;
						};
						advanced = {
							showAllFilenameExtensions = true;
							showWarningBeforeChangingAnExtension = true;
							showWarningBeforeEmptyingTheTrash = true;
							showWarningBeforeRemovingFromiCloudDrive = true;
							removeItemsFromTheTrashAfter30Days = true;
							keepFoldersOnTop = {
								inWindowsWhenSortingByName = true;
								onDesktop = true;
							};
							whenPerformingASearch = "Search the Current Folder";
						};
					};
					menuBar = {
						view = {
							showTabBar = true;
							showSidebar = true;
							showPathBar = true;
							showStatusBar = true;
						};
					};
				};
			};
		};
	};
}

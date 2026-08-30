{
  self,
  lib,
  setup,
  ...
}:
{
  system.defaults = {
    NSGlobalDomain = {
      # Trackpad > Point & Click
      # Secondary click - Click or Tap with Two Fingers
      "com.apple.trackpad.enableSecondaryClick" = true;
      "com.apple.trackpad.trackpadCornerClickBehavior" = null;

      # Trackpad > Point & Click
      # Force Click and haptic feedback - On
      "com.apple.trackpad.forceClick" = true;

      # Trackpad > Point & Click > Tracking speed
      # 4th bar
      "com.apple.trackpad.scaling" = 3.0;

      # Trackpad > Scroll & Zoom
      # Natural scrolling - On
      "com.apple.swipescrolldirection" = true;

      # Trackpad > More Gestures
      # Swipe between pages - Scroll Left or Right with Two Fingers
      AppleEnableSwipeNavigateWithScrolls = true;
    };

    trackpad = {
      # Trackpad > Point & Click > Click
      # Medium
      FirstClickThreshold = 2;
      SecondClickThreshold = 2;
    };

    CustomUserPreferences = lib.attrsets.mergeAttrsList (
      lib.map (user: {
        "~${user}/Library/Preferences/ByHost/com.apple.dock" = {
          # Trackpad > More Gestures (I think)
          # Show Desktop - Off (I think)
          "showDesktopGestureEnabled" = 0;
        };
        "~${user}/Library/Preferences/ByHost/com.apple.AppleMultitouchTrackpad" = {
          # Trackpad > Scroll & Zoom
          # Zoom in or out - On
          "TrackpadPinch" = 1;

          # Trackpad > Scroll & zoom
          # Rotate - On
          "TrackpadRotate" = 1;

          # Trackpad > Scroll & Zoom
          # Smart zoom - On
          "TrackpadTwoFingerDoubleTapGesture" = 1;

          "ActuateDetents" = 1;
          "Clicking" = 1;
          "DragLock" = 0;
          "Dragging" = 0;
          "FirstClickThreshold" = 1;
          "ForceSuppressed" = 0;
          "SecondClickThreshold" = 1;
          "TrackpadCornerSecondaryClick" = 0;
          "TrackpadFiveFingerPinchGesture" = 2;
          "TrackpadFourFingerHorizSwipeGesture" = 2;
          "TrackpadFourFingerPinchGesture" = 2;
          "TrackpadFourFingerVertSwipeGesture" = 2;
          "TrackpadHandResting" = 1;
          "TrackpadHorizScroll" = 1;
          "TrackpadMomentumScroll" = 1;
          "TrackpadRightClick" = 1;
          "TrackpadScroll" = 1;
          "TrackpadThreeFingerDrag" = 0;
          "TrackpadThreeFingerHorizSwipeGesture" = 2;
          "TrackpadThreeFingerTapGesture" = 0;
          "TrackpadThreeFingerVertSwipeGesture" = 2;
          "TrackpadTwoFingerFromRightEdgeSwipeGesture" = 3;
          "USBMouseStopsTrackpad" = 0;
          "UserPreferences" = 1;
          "version" = 12;
        };
      }) setup.managedUsers
    );
  };
}

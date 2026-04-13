{
  config,
  ...
}:
let
  inherit (config.infra.host) user;
in
{
  stateVersion = 6;
  startup.chime = false;
  checks.verifyNixPath = false;

  primaryUser = user;

  defaults = {
    LaunchServices = {
      LSQuarantine = false;
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      AppleMeasurementUnits = "Centimeters";
      AppleShowScrollBars = "Always";
      AppleTemperatureUnit = "Celsius";

      # 120, 90, 60, 30, 12, 6, 2
      KeyRepeat = 2;

      # 120, 94, 68, 35, 25, 15
      InitialKeyRepeat = 15;

      "com.apple.mouse.tapBehavior" = 1;
      "com.apple.sound.beep.volume" = 0.0;
      "com.apple.sound.beep.feedback" = 0;

      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;
      PMPrintingExpandedStateForPrint = true;

      # Not sure how these are related to defaults.trackpad, but better safe than sorry
      "com.apple.trackpad.trackpadCornerClickBehavior" = 1;
    };

    trackpad = {
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
      Clicking = true;
    };

    dock = {
      launchanim = false;
      autohide = true;
      expose-animation-duration = 0.15;
      show-recents = false;
      showhidden = true;
      persistent-apps = [ ];
      mouse-over-hilite-stack = true;
      tilesize = 30;
      orientation = "bottom";
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
    };

    screencapture = {
      location = "/Users/${user}/Downloads/temp";
      type = "png";
      disable-shadow = true;
    };

    finder = {
      AppleShowAllFiles = true;
      CreateDesktop = false;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = false;
      _FXSortFoldersFirst = true;
    };
  };

  keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
    swapLeftCtrlAndFn = false; # DO NOT CHANGE THIS, otherwise Ctrl key stops working on external keyboards
    userKeyMapping = [
      # Remap §± to ~
      # {
      #   HIDKeyboardModifierMappingDst = 30064771125;
      #   HIDKeyboardModifierMappingSrc = 30064771172;
      # }
      # # Remap `Ctrl+Backspace` to `Forward Delete`
      # {
      #
      #   HIDKeyboardModifierMappingDst = 30064771306;
      #   HIDKeyboardModifierMappingSrc = 30064771148;
      # }
    ];
  };
}

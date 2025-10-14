class AppConstants {
  static const String appName = 'Walkie';
  
  static const String splashRouteName = 'splash';
  static const String loginRouteName = 'login';
  static const String homeRouteName = 'home';
  static const String callRouteName = 'call';
  
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String loginButtonText = 'Login';
  static const String signupButtonText = 'Sign Up';
  static const String forgotPasswordText = 'Forgot Password?';
  static const String noAccountText = "Don't have an account? ";
  static const String haveAccountText = 'Already have an account? ';
  
  static const String noFriendsFound = 'No friends found';
  static const String addFriendsText = 'Add friends to see them here';
  static const String loadingUsersText = 'Loading users from Firebase...';
  static const String connectingDatabaseText = 'Connecting to real-time database';
  static const String errorLoadingFriends = 'Error loading friends';
  static const String retryButtonText = 'Retry';
  static const String cleanSignalsButtonText = 'Clean Signals';
  
  static const String profileFeatureComingSoon = 'Profile feature coming soon!';
  static const String settingsFeatureComingSoon = 'Settings feature coming soon!';
  
  static const String logoutDialogTitle = 'Logout';
  static const String logoutDialogContent = 'Are you sure you want to logout?';
  static const String cancelButtonText = 'Cancel';
  static const String logoutButtonText = 'Logout';
  
  static const String cleanupDialogTitle = 'Clean Firebase Signals';
  static const String cleanupDialogContent = 'This will remove all signal data from Firebase Realtime Database. '
      'This includes all call requests, offers, answers, and ICE candidates.\n\n'
      'Are you sure you want to proceed?';
  static const String cleaningUpText = 'Cleaning up signals...';
  static const String cleanedUpSignalsText = '✅ Cleaned up signals from Firebase!';
  static const String failedToCleanSignalsText = '❌ Failed to clean signals:';
  
  static const String testingHandshakeText = '🧪 Testing handshake:';
  static const String callTestInitiatedText = '✅ Call test initiated!';
  static const String handshakeTestFailedText = '❌ Handshake test failed:';
  static const String testingFirebaseListenerText = '🧪 Testing Firebase listener for user:';
  static const String firebaseListenerTestCompletedText = '✅ Firebase listener test completed! Check logs.';
  static const String firebaseListenerTestFailedText = '❌ Firebase listener test failed:';
  static const String foundHandshakeText = '🎯 Found handshake for you from:';
  static const String noAuthenticatedUserText = '❌ No authenticated user found';
  
  static const String profileTooltip = 'Profile';
  static const String cleanSignalsTooltip = 'Clean Firebase Signals';
  static const String testHandshakeTooltip = 'Test Handshake';
  static const String testFirebaseListenerTooltip = 'Test Firebase Listener';
  static const String settingsTooltip = 'Settings';
  static const String logoutTooltip = 'Logout';
  
  static const String profileIcon = 'Icons.person';
  static const String cleaningServicesIcon = 'Icons.cleaning_services';
  static const String bugReportIcon = 'Icons.bug_report';
  static const String wifiIcon = 'Icons.wifi';
  static const String settingsIcon = 'Icons.settings';
  static const String logoutIcon = 'Icons.logout';
  static const String peopleOutlineIcon = 'Icons.people_outline';
  static const String errorOutlineIcon = 'Icons.error_outline';
  static const String circularProgressIcon = 'CircularProgressIndicator';
  
  static const String orangeColor = 'Colors.orange';
  static const String greenColor = 'Colors.green';
  static const String redColor = 'Colors.red';
  static const String blueColor = 'Colors.blue';
  static const String greyColor = 'Colors.grey';
  static const String whiteColor = 'Colors.white';
  static const String blackColor = 'Colors.black';
  
  static const int defaultIconSize = 64;
  static const int defaultFontSize = 18;
  static const int smallFontSize = 14;
  static const int mediumFontSize = 16;
  static const int largeFontSize = 18;
  
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 16.0;
  
  static const Duration defaultSnackBarDuration = Duration(seconds: 3);
  static const Duration defaultDialogDuration = Duration(seconds: 10);
}


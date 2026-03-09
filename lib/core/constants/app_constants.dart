class AppConstants {
  const AppConstants._();

  static const String appName = 'Alszik a Város';
  static const int mvpPlayerCount = 6;
  static const Duration networkTimeout = Duration(seconds: 15);
  static const Duration reconnectDelay = Duration(seconds: 3);

  // Enable with: flutter run --dart-define=USE_MOCK_BACKEND=true
  static const bool useMockBackend =
      bool.fromEnvironment('USE_MOCK_BACKEND', defaultValue: false);

  // Enable with: flutter run --dart-define=ENABLE_NETWORK_LOGS=true
  static const bool enableNetworkLogs =
      bool.fromEnvironment('ENABLE_NETWORK_LOGS', defaultValue: false);
}

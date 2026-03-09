class ApiConstants {
  const ApiConstants._();

  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _wsBaseUrlOverride = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: '',
  );

  static const String _apiScheme = String.fromEnvironment(
    'API_SCHEME',
    defaultValue: 'http',
  );
  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'localhost',
  );
  static const String _apiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '18080',
  );
  static const String _wsPath = String.fromEnvironment(
    'WS_PATH',
    defaultValue: '/ws',
  );

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }
    return '$_apiScheme://$_apiHost:$_apiPort';
  }

  static String get wsBaseUrl {
    if (_wsBaseUrlOverride.isNotEmpty) {
      return _wsBaseUrlOverride;
    }
    const wsScheme = _apiScheme == 'https' ? 'wss' : 'ws';
    return '$wsScheme://$_apiHost:$_apiPort$_wsPath';
  }
}

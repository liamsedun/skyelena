class AppConstants {
  static const String appName = 'SkyElena';
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String wsUrl = 'ws://10.0.2.2:3000/ws';

  static const Duration requestTimeout = Duration(seconds: 30);

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}

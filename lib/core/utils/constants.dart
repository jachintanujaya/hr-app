class ApiConstants {
  // Replace with your real backend base URL
  static const String baseUrl = 'https://api.your-hr-app.com/v1';

  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String currentUser = '/auth/me';

  static const String attendance = '/attendance';
  static const String clockIn = '/attendance/clock-in';
  static const String clockOut = '/attendance/clock-out';
  static const String teamAttendance = '/attendance/team';

  static const String timeOffRequests = '/time-off/requests';
  static const String timeOffBalances = '/time-off/balances';
  static const String timeOffPolicies = '/time-off/policies';

  static const String employees = '/employees';
}

class StorageKeys {
  static const String accessToken = 'ACCESS_TOKEN';
  static const String refreshToken = 'REFRESH_TOKEN';
  static const String cachedUser = 'CACHED_USER';
}

class AppDurations {
  static const Duration apiTimeout = Duration(seconds: 30);
}

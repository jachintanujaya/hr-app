/// Exceptions thrown by data sources (remote/local).
/// These get caught in repository implementations and mapped to Failures.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection']);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Session expired, please login again']);
}

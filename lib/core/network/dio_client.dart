import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../utils/constants.dart';

/// Configures a single Dio instance shared across all feature data sources.
/// Handles attaching the access token and refreshing it on 401s.
class DioClient {
  static Dio create(FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppDurations.apiTimeout,
        receiveTimeout: AppDurations.apiTimeout,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: StorageKeys.accessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // TODO: implement refresh-token flow here, retry original request.
            // For now we let it bubble up; AuthBloc/router will redirect to login.
          }
          handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        compact: true,
      ),
    );

    return dio;
  }
}

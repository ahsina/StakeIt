import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../core/config/app_config.dart';
import 'storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiClient(storage).dio;
});

class ApiClient {
  late final Dio dio;
  final StorageService _storage;
  final Logger _logger = Logger();

  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request Interceptor - Add auth token to requests
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
        );
        return handler.next(response);
      },
      onError: (error, handler) async {
        _logger.e(
          'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
        );

        // Handle 401 Unauthorized - Token expired
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          // final refreshed = await _refreshToken();
          // if (refreshed) {
          //   // Retry the request
          //   return handler.resolve(await _retry(error.requestOptions));
          // }
        }

        return handler.next(error);
      },
    ));

    // Logging Interceptor
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => _logger.d(object),
    ));
  }

  // Retry a failed request
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Refresh token logic
  // Future<bool> _refreshToken() async {
  //   try {
  //     final refreshToken = await _storage.getRefreshToken();
  //     if (refreshToken == null) return false;
  //
  //     final response = await dio.post(
  //       '/api/auth/refresh',
  //       data: {'refreshToken': refreshToken},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final newToken = response.data['token'] as String;
  //       await _storage.saveAccessToken(newToken);
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }
}

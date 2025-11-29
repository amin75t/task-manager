import 'package:dio/dio.dart';
import 'package:task_manager/core/api/api_constants.dart';
import 'package:task_manager/core/api/interceptors/auth_interceptor.dart';
import 'package:task_manager/core/api/interceptors/logging_interceptor.dart';

/// Base API Client using Dio
///
/// This class provides a configured Dio instance with:
/// - Base URL configuration
/// - Timeout settings
/// - Authentication interceptor
/// - Logging interceptor
/// - Error handling
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  /// Base options for all requests
  BaseOptions get _baseOptions => BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Accept': ApiConstants.accept,
        },
        validateStatus: (status) {
          // Accept all status codes and handle them in interceptors
          return status != null && status < 500;
        },
      );

  /// Setup interceptors
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  /// Dio instance getter
  Dio get dio => _dio;

  // ============================================================================
  // HTTP METHODS
  // ============================================================================

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  /// Handle Dio errors and convert them to custom exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = _extractErrorMessage(error.response?.data);
        return ApiException(
          message: message,
          statusCode: statusCode,
          data: error.response?.data,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Request cancelled');

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Invalid SSL certificate.',
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: error.message ?? 'An unexpected error occurred.',
        );
    }
  }

  /// Extract error message from response
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'An error occurred';

    if (data is Map<String, dynamic>) {
      // Try common error message fields
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final firstError = detail.first;
          if (firstError is Map && firstError.containsKey('msg')) {
            return firstError['msg'].toString();
          }
        }
      }

      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
    }

    return 'An error occurred';
  }
}

// ============================================================================
// CUSTOM EXCEPTION
// ============================================================================

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $message (Status: $statusCode)';
    }
    return 'ApiException: $message';
  }

  /// Check if error is authentication related
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if error is validation related
  bool get isValidationError => statusCode == 422;

  /// Check if error is not found
  bool get isNotFoundError => statusCode == 404;

  /// Check if error is server error
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

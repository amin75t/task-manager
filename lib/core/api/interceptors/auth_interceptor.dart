import 'package:dio/dio.dart';
import 'package:task_manager/core/api/api_constants.dart';
import 'package:task_manager/core/services/token_service.dart';

/// Authentication Interceptor
///
/// Automatically adds JWT bearer token to requests that require authentication
class AuthInterceptor extends Interceptor {
  final TokenService _tokenService = TokenService();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await _tokenService.getToken();

    // Add authorization header if token exists
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorizationHeader] =
          ApiConstants.bearerToken(token);
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - clear token and redirect to login
    if (err.response?.statusCode == 401) {
      await _tokenService.clearToken();
      // You can add navigation to login screen here if needed
    }

    super.onError(err, handler);
  }
}

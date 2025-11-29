import 'package:dio/dio.dart';

/// Logging Interceptor
///
/// Logs all HTTP requests and responses for debugging purposes
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌──────────────────────────────────────────────────');
    print('│ REQUEST: ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('│ Query Parameters: ${options.queryParameters}');
    }
    print('└──────────────────────────────────────────────────');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌──────────────────────────────────────────────────');
    print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Headers: ${response.headers}');
    print('│ Body: ${response.data}');
    print('└──────────────────────────────────────────────────');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌──────────────────────────────────────────────────');
    print('│ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('│ Status Code: ${err.response?.statusCode}');
    print('│ Message: ${err.message}');
    if (err.response?.data != null) {
      print('│ Error Data: ${err.response?.data}');
    }
    print('└──────────────────────────────────────────────────');

    super.onError(err, handler);
  }
}

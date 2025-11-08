import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  final Logger logger = Logger('DioLogger');

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.severe('${options.method} request ==> $requestPath ');
    logger.warning(
      'Error type: ${err.error} \n'
      'Error message: ${err.message}',
    );
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    final queryParams = options.queryParameters.isNotEmpty
        ? ' | Query: ${options.queryParameters}'
        : '';

    logger.info('${options.method} request ==> $requestPath$queryParams');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.fine(
      'STATUSCODE: ${response.statusCode} \n'
      'STATUSMESSAGE: ${response.statusMessage} \n'
      'HEADERS: ${response.headers} \n'
      'DATA: ${response.data}',
    );
    handler.next(response);
  }
}

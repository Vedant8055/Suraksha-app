import 'package:dio/dio.dart';
import 'package:suraksha_women_safety_app/core/activity_log/app_activity_log.dart';

class ActivityLogDioInterceptor extends Interceptor {
  static const _skip = {'/health', '/location/update', '/auth/refresh'};

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _write(response.requestOptions, response.statusCode ?? 0);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _write(err.requestOptions, err.response?.statusCode ?? 0, failed: true);
    handler.next(err);
  }

  void _write(RequestOptions options, int status, {bool failed = false}) {
    final path = options.path;
    if (_skip.any(path.contains)) return;
    AppActivityLog.instance.record(
      failed ? 'api_error' : 'api_call',
      details: {
        'method': options.method,
        'path': path.split('?').first,
        'status': '$status',
      },
    );
  }
}

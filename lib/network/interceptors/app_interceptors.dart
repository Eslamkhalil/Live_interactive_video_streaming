import 'package:dio/dio.dart';
import 'package:live_chat_app/network/token_services/token_service.dart';

class AppInterceptors extends Interceptor {
  final Dio client;
  final ITokenService tokenService;

  AppInterceptors(this.client, this.tokenService);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final String? accessToken = await tokenService.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Unauthorized error
      final String? newAccessToken =
          await tokenService.refreshAccessToken(client);

      if (newAccessToken != null) {
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';

        return handler.resolve(await _retry(options));
      }
    }
    return handler.next(err); // Continue with the error if token refresh fails
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return client.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

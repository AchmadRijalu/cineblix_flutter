import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

Dio fakeDio(Map<String, (int, Object)> routes, {List<RequestOptions>? log}) =>
    Dio(BaseOptions(baseUrl: 'https://test'))
      ..httpClientAdapter = _FakeAdapter(routes, log);

class _FakeAdapter implements HttpClientAdapter {
  final Map<String, (int, Object)> routes;
  final List<RequestOptions>? log;
  _FakeAdapter(this.routes, this.log);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    log?.add(options);
    final (status, body) =
        routes['${options.path}?${options.uri.query}'] ??
        routes[options.path] ??
        (404, {'status_message': 'not found'});
    if (status == 0) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

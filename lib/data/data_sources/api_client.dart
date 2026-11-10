part of 'data_sources.dart';

Dio createDio() {
  if (apiKey.isEmpty) {
    throw StateError(
      'TMDB_API_KEY is missing. Run with --dart-define-from-file=env.json',
    );
  }
  return Dio(
    BaseOptions(baseUrl: baseUrl, queryParameters: {'api_key': apiKey}),
  );
}

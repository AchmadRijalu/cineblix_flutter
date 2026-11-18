part of 'commons.dart';

/// Trusts only Amazon Root CA 1, the root of api.themoviedb.org's chain.
/// Pinning the root (not the leaf) survives TMDB's ~6-monthly leaf rotation.
Future<SecurityContext> pinnedSecurityContext() async {
  final cert = await rootBundle.load(
    'packages/core/certificates/amazon_root_ca_1.pem',
  );
  return SecurityContext()
    ..setTrustedCertificatesBytes(cert.buffer.asUint8List());
}

Dio createDio(SecurityContext context, [String key = apiKey]) {
  if (key.isEmpty) {
    throw StateError(
      'TMDB_API_KEY is missing. Run with --dart-define-from-file=env.json',
    );
  }
  return Dio(BaseOptions(baseUrl: baseUrl, queryParameters: {'api_key': key}))
    ..httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient(context: context)
        ..badCertificateCallback = (_, _, _) => false,
    );
}

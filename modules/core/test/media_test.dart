import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  test('media categories know their media type and title', () {
    expect(
      [for (final c in MediaCategory.values) (c.type, c.title)],
      [
        (MediaType.movie, 'Now Playing'),
        (MediaType.movie, 'Popular'),
        (MediaType.movie, 'Top Rated'),
        (MediaType.tv, 'On The Air'),
        (MediaType.tv, 'Popular'),
        (MediaType.tv, 'Top Rated'),
      ],
    );
  });

  test('createDio refuses to run without an API key', () {
    expect(() => createDio(SecurityContext()), throwsStateError);
  });

  test('createDio builds a client for the TMDB API with the given key', () {
    final dio = createDio(SecurityContext(), 'secret');
    expect(dio.options.baseUrl, baseUrl);
    expect(dio.options.queryParameters, {'api_key': 'secret'});
  });

  test('pinned certificate is a valid PEM', () {
    expect(
      () => SecurityContext()
        ..setTrustedCertificates('certificates/amazon_root_ca_1.pem'),
      returnsNormally,
    );
  });

  test('initCore registers the Dio client lazily', () {
    final locator = GetIt.asNewInstance();
    initCore(locator);
    expect(locator.isRegistered<Dio>(), isTrue);
    expect(locator.get<Dio>, throwsStateError);
  });
}

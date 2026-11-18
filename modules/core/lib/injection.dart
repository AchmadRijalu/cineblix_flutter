import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'utils/commons.dart';

/// Expects a [SecurityContext] from [pinnedSecurityContext] to be registered
/// before the first [Dio] lookup, so requests can never go out unpinned.
void initCore(GetIt locator) {
  locator.registerLazySingleton<Dio>(
    () => createDio(locator<SecurityContext>()),
  );
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'utils/commons.dart';

void initCore(GetIt locator) {
  locator.registerLazySingleton<Dio>(
    () => createDio(locator<SecurityContext>()),
    
  );
}

import 'dart:ui';

import 'package:core/core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:home/home.dart';

import 'firebase_options.dart';
import 'injection.dart';
import 'navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  locator.registerSingleton(await pinnedSecurityContext());
  init();
  runApp(
    MyApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.navigatorObservers = const []});

  final List<NavigatorObserver> navigatorObservers;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cineblix',
      navigatorObservers: navigatorObservers,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(
        onMovieTap: openMovie,
        onTvTap: openTv,
        onSeeMore: openSeeMore,
        onSearch: openSearch,
        onWatchlist: openWatchlist,
        onAbout: openAbout,
      ),
    );
  }
}

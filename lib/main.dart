import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:home/home.dart';

import 'injection.dart';
import 'navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locator.registerSingleton(await pinnedSecurityContext());
  init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cineblix',
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

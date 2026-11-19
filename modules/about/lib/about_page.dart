part of 'about.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(
                  Icons.movie_filter_rounded,
                  size: 96,
                  color: colors.primary,
                ),
                const SizedBox(height: 16),
                Text('Cineblix', style: textTheme.headlineMedium),
                const SizedBox(height: 24),
                Text(
                  'Cineblix is a catalog app for movies and TV series. Browse '
                  'what is playing now, what is popular and what is top rated, '
                  'read the details of every title, explore seasons and '
                  'episodes, search for TV series, and keep the titles you '
                  'want to watch in your watchlist.',
                  textAlign: TextAlign.justify,
                  style: textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),
                Text(
                  'This product uses the TMDB API but is not endorsed or '
                  'certified by The Movie Database (TMDB).',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: colors.outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

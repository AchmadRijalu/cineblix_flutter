part of 'presentation.dart';

class SeasonPage extends StatelessWidget {
  final int tvId;
  final int seasonNumber;
  final String title;

  const SeasonPage({
    super.key,
    required this.tvId,
    required this.seasonNumber,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        GetIt.instance<SeasonBloc>()..add(SeasonFetched(tvId, seasonNumber)),
    child: Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<SeasonBloc, SeasonState>(
        builder: (context, state) => switch (state) {
          SeasonInitial() || SeasonLoading() => const CustomLoadingAnimation(
            isLoading: true,
            barrierColor: Colors.transparent,
            child: SizedBox.expand(),
          ),
          SeasonError(:final message) => CustomErrorItem(
            message: message,
            onRetry: () => context.read<SeasonBloc>().add(
              SeasonFetched(tvId, seasonNumber),
            ),
          ),
          SeasonLoaded(:final season) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (season.overview.isNotEmpty) ...[
                Text(season.overview),
                const SizedBox(height: 16),
              ],
              for (final episode in season.episodes)
                PosterTile(
                  posterPath: episode.stillPath,
                  title: 'E${episode.episodeNumber} · ${episode.name}',
                  subtitle: '${_episodeInfo(episode)}\n${episode.overview}',
                ),
            ],
          ),
        },
      ),
    ),
  );

  static String _episodeInfo(Episode episode) => [
    '★ ${episode.voteAverage.toStringAsFixed(1)}',
    if (episode.runtime > 0) '${episode.runtime} min',
    if (episode.airDate.isNotEmpty) episode.airDate,
  ].join(' · ');
}

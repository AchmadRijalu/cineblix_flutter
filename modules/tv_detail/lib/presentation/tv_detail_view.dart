part of 'presentation.dart';

class TvDetailView extends StatelessWidget {
  final int id;
  final void Function(BuildContext context, int id) onRecommendationTap;
  final void Function(
    BuildContext context,
    int tvId,
    int seasonNumber,
    String title,
  )
  onSeasonTap;

  const TvDetailView({
    super.key,
    required this.id,
    required this.onRecommendationTap,
    required this.onSeasonTap,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.instance<TvDetailBloc>()..add(TvDetailFetched(id)),
    child: Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<TvDetailBloc, TvDetailState>(
            builder: (context, state) => state is TvDetailLoaded
                ? WatchlistIconButton(
                    isAdded: state.isAddedToWatchlist,
                    onPressed: () => context.read<TvDetailBloc>().add(
                      TvDetailWatchlistToggled(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: BlocConsumer<TvDetailBloc, TvDetailState>(
        listenWhen: (_, curr) =>
            curr is TvDetailLoaded && curr.watchlistMessage.isNotEmpty,
        listener: (context, state) {
          final loaded = state as TvDetailLoaded;
          showAppSnack(
            context,
            loaded.watchlistMessage,
            isError: loaded.watchlistFailed,
          );
        },
        builder: (context, state) => switch (state) {
          TvDetailInitial() ||
          TvDetailLoading() => const CustomLoadingAnimation(
            isLoading: true,
            barrierColor: Colors.transparent,
            child: SizedBox.expand(),
          ),
          TvDetailError(:final message) => CustomErrorItem(
            message: message,
            onRetry: () =>
                context.read<TvDetailBloc>().add(TvDetailFetched(id)),
          ),
          TvDetailLoaded() => _Content(
            state,
            onRecommendationTap: onRecommendationTap,
            onSeasonTap: onSeasonTap,
          ),
        },
      ),
    ),
  );
}

class _Content extends StatelessWidget {
  final TvDetailLoaded state;
  final void Function(BuildContext context, int id) onRecommendationTap;
  final void Function(
    BuildContext context,
    int tvId,
    int seasonNumber,
    String title,
  )
  onSeasonTap;

  const _Content(
    this.state, {
    required this.onRecommendationTap,
    required this.onSeasonTap,
  });

  @override
  Widget build(BuildContext context) {
    final tv = state.tv;
    final textTheme = Theme.of(context).textTheme;
    final info = [
      if (tv.genres.isNotEmpty) tv.genres.join(', '),
      if (tv.numberOfSeasons > 0)
        '${tv.numberOfSeasons} season${tv.numberOfSeasons == 1 ? '' : 's'}',
    ].join(' · ');

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Center(
          child: SizedBox(
            height: 300,
            child: PosterCard(posterPath: tv.posterPath, width: 200),
          ),
        ),
        const SizedBox(height: 12),
        Text(tv.name, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '★ ${tv.voteAverage.toStringAsFixed(1)}',
          style: textTheme.titleMedium,
        ),
        if (info.isNotEmpty) Text(info),
        const SizedBox(height: 12),
        Text('Synopsis', style: textTheme.titleLarge),
        Text(tv.overview.isEmpty ? 'No synopsis available.' : tv.overview),
        if (tv.seasons.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Seasons', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final season in tv.seasons)
            PosterTile(
              posterPath: season.posterPath,
              title: season.name,
              subtitle: [
                '${season.episodeCount} episodes',
                if (season.airDate.length >= 4) season.airDate.substring(0, 4),
              ].join(' · '),
              onTap: () =>
                  onSeasonTap(context, tv.id, season.seasonNumber, season.name),
            ),
        ],
        const SizedBox(height: 16),
        Text('Recommendations', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        if (state.recommendations.isEmpty)
          const Text('No recommendations.')
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.recommendations.length,
              itemBuilder: (context, i) => PosterCard(
                posterPath: state.recommendations[i].posterPath,
                onTap: () =>
                    onRecommendationTap(context, state.recommendations[i].id),
              ),
            ),
          ),
      ],
    );
  }
}

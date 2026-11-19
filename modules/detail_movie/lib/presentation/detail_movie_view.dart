part of 'presentation.dart';

class DetailMovieView extends StatelessWidget {
  final int id;
  final void Function(BuildContext context, int id) onRecommendationTap;

  const DetailMovieView({
    super.key,
    required this.id,
    required this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        GetIt.instance<DetailMovieBloc>()..add(DetailMovieFetched(id)),
    child: Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<DetailMovieBloc, DetailMovieState>(
            builder: (context, state) => state is DetailMovieLoaded
                ? WatchlistIconButton(
                    isAdded: state.isAddedToWatchlist,
                    onPressed: () => context.read<DetailMovieBloc>().add(
                      DetailMovieWatchlistToggled(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: BlocConsumer<DetailMovieBloc, DetailMovieState>(
        listenWhen: (_, curr) =>
            curr is DetailMovieLoaded && curr.watchlistMessage.isNotEmpty,
        listener: (context, state) {
          final loaded = state as DetailMovieLoaded;
          showAppSnack(
            context,
            loaded.watchlistMessage,
            isError: loaded.watchlistFailed,
          );
        },
        builder: (context, state) => switch (state) {
          DetailMovieInitial() ||
          DetailMovieLoading() => const CustomLoadingAnimation(
            isLoading: true,
            barrierColor: Colors.transparent,
            child: SizedBox.expand(),
          ),
          DetailMovieError(:final message) => CustomErrorItem(
            message: message,
            onRetry: () =>
                context.read<DetailMovieBloc>().add(DetailMovieFetched(id)),
          ),
          DetailMovieLoaded(:final movie, :final recommendations) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Center(
                child: SizedBox(
                  height: 300,
                  child: PosterCard(posterPath: movie.posterPath, width: 200),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                movie.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                '${movie.genres.join(', ')} · ${movie.runtime} min · ★ ${movie.voteAverage.toStringAsFixed(1)}',
              ),
              const SizedBox(height: 12),
              Text(movie.overview),
              const SizedBox(height: 16),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendations.length,
                  itemBuilder: (context, i) => PosterCard(
                    posterPath: recommendations[i].posterPath,
                    onTap: () =>
                        onRecommendationTap(context, recommendations[i].id),
                  ),
                ),
              ),
            ],
          ),
        },
      ),
    ),
  );
}

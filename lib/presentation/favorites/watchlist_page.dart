part of 'favorites.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => locator<WatchlistBloc>()..add(WatchlistFetched()),
    child: Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) => switch (state) {
          WatchlistInitial() ||
          WatchlistLoading() => const CustomLoadingAnimation(
            isLoading: true,
            barrierColor: Colors.transparent,
            child: SizedBox.expand(),
          ),
          WatchlistError(:final message) => CustomErrorItem(
            message: message,
            onRetry: () =>
                context.read<WatchlistBloc>().add(WatchlistFetched()),
          ),
          WatchlistLoaded(:final items) when items.isEmpty => const Center(
            child: Text('Your watchlist is empty'),
          ),
          WatchlistLoaded(:final items) => ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) => PosterTile(
              posterPath: items[i].posterPath,
              title: items[i].title,
              subtitle:
                  '★ ${items[i].voteAverage.toStringAsFixed(1)}\n${items[i].overview ?? ''}',
              onTap: () async {
                final bloc = context.read<WatchlistBloc>();
                final item = items[i];
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => switch (item.type) {
                      MediaType.tv => TvDetailView(id: item.id),
                      MediaType.movie => DetailMovieView(id: item.id),
                    },
                  ),
                );
                bloc.add(WatchlistFetched());
              },
            ),
          ),
        },
      ),
    ),
  );
}

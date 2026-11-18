part of 'presentation.dart';

class WatchlistPage extends StatelessWidget {
  final Future<void> Function(BuildContext context, MediaItem item) onItemTap;
  const WatchlistPage({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.instance<WatchlistBloc>()..add(WatchlistFetched()),
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
                await onItemTap(context, items[i]);
                bloc.add(WatchlistFetched());
              },
            ),
          ),
        },
      ),
    ),
  );
}

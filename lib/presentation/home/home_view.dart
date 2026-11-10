part of 'home.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Search TV series',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
          IconButton(
            tooltip: 'Watchlist',
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WatchlistPage()),
            ),
          ),
        ],
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Movies'),
            Tab(text: 'TV Series'),
          ],
        ),
      ),
      body: const TabBarView(children: [_MovieList(), _TvList()]),
    ),
  );
}

class _MovieList extends StatelessWidget {
  const _MovieList();

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeBloc, HomeState>(
    builder: (context, state) => switch (state) {
      HomeInitial() || HomeLoading() => const CustomLoadingAnimation(
        isLoading: true,
        barrierColor: Colors.transparent,
        child: SizedBox.expand(),
      ),
      HomeError(:final message) => CustomErrorItem(
        message: message,
        onRetry: () => context.read<HomeBloc>().add(HomeFetched()),
      ),
      HomeLoaded() => RefreshIndicator(
        onRefresh: () async => context.read<HomeBloc>().add(HomeFetched()),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _MovieSection(MediaCategory.nowPlaying, state.nowPlaying),
            _MovieSection(MediaCategory.popularMovies, state.popular),
            _MovieSection(MediaCategory.topRatedMovies, state.topRated),
          ],
        ),
      ),
    },
  );
}

class _MovieSection extends StatelessWidget {
  final MediaCategory category;
  final List<Movie> movies;
  const _MovieSection(this.category, this.movies);

  @override
  Widget build(BuildContext context) => PosterSection(
    title: category.title,
    posterPaths: [for (final movie in movies) movie.posterPath],
    onSeeMore: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeeMorePage(title: category.title, category: category),
      ),
    ),
    onTap: (i) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailMovieView(id: movies[i].id)),
    ),
  );
}

class _TvList extends StatelessWidget {
  const _TvList();

  @override
  Widget build(BuildContext context) => BlocBuilder<HomeTvBloc, HomeTvState>(
    builder: (context, state) => switch (state) {
      HomeTvInitial() || HomeTvLoading() => const CustomLoadingAnimation(
        isLoading: true,
        barrierColor: Colors.transparent,
        child: SizedBox.expand(),
      ),
      HomeTvError(:final message) => CustomErrorItem(
        message: message,
        onRetry: () => context.read<HomeTvBloc>().add(HomeTvFetched()),
      ),
      HomeTvLoaded() => RefreshIndicator(
        onRefresh: () async => context.read<HomeTvBloc>().add(HomeTvFetched()),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _TvSection(MediaCategory.onTheAir, state.onTheAir),
            _TvSection(MediaCategory.popularTv, state.popular),
            _TvSection(MediaCategory.topRatedTv, state.topRated),
          ],
        ),
      ),
    },
  );
}

class _TvSection extends StatelessWidget {
  final MediaCategory category;
  final List<Tv> tvs;
  const _TvSection(this.category, this.tvs);

  @override
  Widget build(BuildContext context) => PosterSection(
    title: category.title,
    posterPaths: [for (final tv in tvs) tv.posterPath],
    onSeeMore: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeeMorePage(title: category.title, category: category),
      ),
    ),
    onTap: (i) => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TvDetailView(id: tvs[i].id)),
    ),
  );
}

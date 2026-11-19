part of 'presentation.dart';

class HomeView extends StatelessWidget {
  final void Function(BuildContext context, int id) onMovieTap;
  final void Function(BuildContext context, int id) onTvTap;
  final void Function(BuildContext context, MediaCategory category) onSeeMore;
  final void Function(BuildContext context) onSearch;
  final void Function(BuildContext context) onWatchlist;
  final void Function(BuildContext context) onAbout;

  const HomeView({
    super.key,
    required this.onMovieTap,
    required this.onTvTap,
    required this.onSeeMore,
    required this.onSearch,
    required this.onWatchlist,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Search TV series',
            icon: const Icon(Icons.search),
            onPressed: () => onSearch(context),
          ),
          IconButton(
            tooltip: 'Watchlist',
            icon: const Icon(Icons.favorite),
            onPressed: () => onWatchlist(context),
          ),
          IconButton(
            tooltip: 'About',
            icon: const Icon(Icons.info),
            onPressed: () => onAbout(context),
          ),
        ],
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Movies'),
            Tab(text: 'TV Series'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _MovieList(onTap: onMovieTap, onSeeMore: onSeeMore),
          _TvList(onTap: onTvTap, onSeeMore: onSeeMore),
        ],
      ),
    ),
  );
}

class _MovieList extends StatelessWidget {
  final void Function(BuildContext context, int id) onTap;
  final void Function(BuildContext context, MediaCategory category) onSeeMore;
  const _MovieList({required this.onTap, required this.onSeeMore});

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
            _MovieSection(
              MediaCategory.nowPlaying,
              state.nowPlaying,
              onTap,
              onSeeMore,
            ),
            _MovieSection(
              MediaCategory.popularMovies,
              state.popular,
              onTap,
              onSeeMore,
            ),
            _MovieSection(
              MediaCategory.topRatedMovies,
              state.topRated,
              onTap,
              onSeeMore,
            ),
          ],
        ),
      ),
    },
  );
}

class _MovieSection extends StatelessWidget {
  final MediaCategory category;
  final List<Movie> movies;
  final void Function(BuildContext context, int id) onTap;
  final void Function(BuildContext context, MediaCategory category) onSeeMore;
  const _MovieSection(this.category, this.movies, this.onTap, this.onSeeMore);

  @override
  Widget build(BuildContext context) => PosterSection(
    title: category.title,
    posterPaths: [for (final movie in movies) movie.posterPath],
    onSeeMore: () => onSeeMore(context, category),
    onTap: (i) => onTap(context, movies[i].id),
  );
}

class _TvList extends StatelessWidget {
  final void Function(BuildContext context, int id) onTap;
  final void Function(BuildContext context, MediaCategory category) onSeeMore;
  const _TvList({required this.onTap, required this.onSeeMore});

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
            _TvSection(
              MediaCategory.onTheAir,
              state.onTheAir,
              onTap,
              onSeeMore,
            ),
            _TvSection(
              MediaCategory.popularTv,
              state.popular,
              onTap,
              onSeeMore,
            ),
            _TvSection(
              MediaCategory.topRatedTv,
              state.topRated,
              onTap,
              onSeeMore,
            ),
          ],
        ),
      ),
    },
  );
}

class _TvSection extends StatelessWidget {
  final MediaCategory category;
  final List<Tv> tvs;
  final void Function(BuildContext context, int id) onTap;
  final void Function(BuildContext context, MediaCategory category) onSeeMore;
  const _TvSection(this.category, this.tvs, this.onTap, this.onSeeMore);

  @override
  Widget build(BuildContext context) => PosterSection(
    title: category.title,
    posterPaths: [for (final tv in tvs) tv.posterPath],
    onSeeMore: () => onSeeMore(context, category),
    onTap: (i) => onTap(context, tvs[i].id),
  );
}

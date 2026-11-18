part of 'presentation.dart';

class HomePage extends StatelessWidget {
  final void Function(BuildContext context, int id) onMovieTap;
  final void Function(BuildContext context, int id) onTvTap;
  final void Function(BuildContext context, MediaCategory category) onSeeMore;
  final void Function(BuildContext context) onSearch;
  final void Function(BuildContext context) onWatchlist;
  final void Function(BuildContext context) onAbout;

  const HomePage({
    super.key,
    required this.onMovieTap,
    required this.onTvTap,
    required this.onSeeMore,
    required this.onSearch,
    required this.onWatchlist,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => GetIt.instance<HomeBloc>()..add(HomeFetched()),
      ),
      BlocProvider(
        create: (_) => GetIt.instance<HomeTvBloc>()..add(HomeTvFetched()),
      ),
    ],
    child: HomeView(
      onMovieTap: onMovieTap,
      onTvTap: onTvTap,
      onSeeMore: onSeeMore,
      onSearch: onSearch,
      onWatchlist: onWatchlist,
      onAbout: onAbout,
    ),
  );
}

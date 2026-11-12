part of 'presentation.dart';

class SearchPage extends StatelessWidget {
  final void Function(BuildContext context, int id) onItemTap;
  const SearchPage({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => GetIt.instance<SearchBloc>(),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Search TV Series')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: CustomFormField(
                title: null,
                isShowTitle: false,
                hintText: 'Search TV series',
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (q) =>
                    context.read<SearchBloc>().add(SearchQueryChanged(q)),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) => switch (state) {
                  SearchInitial() => const Center(
                    child: Text('Type a title and press search'),
                  ),
                  SearchLoading() => const CustomLoadingAnimation(
                    isLoading: true,
                    barrierColor: Colors.transparent,
                    child: SizedBox.expand(),
                  ),
                  SearchEmpty(:final query) => Center(
                    child: Text('No TV series found for "$query"'),
                  ),
                  SearchError(:final message) => CustomErrorItem(
                    message: message,
                  ),
                  SearchLoaded(:final results) => ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: results.length,
                    itemBuilder: (context, i) => PosterTile(
                      posterPath: results[i].posterPath,
                      title: results[i].name,
                      subtitle:
                          '★ ${results[i].voteAverage.toStringAsFixed(1)}\n${results[i].overview ?? ''}',
                      onTap: () => onItemTap(context, results[i].id),
                    ),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

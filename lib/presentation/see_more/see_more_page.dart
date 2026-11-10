part of 'see_more.dart';

class SeeMorePage extends StatelessWidget {
  final String title;
  final MediaCategory category;
  const SeeMorePage({super.key, required this.title, required this.category});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        locator<SeeMoreBloc>(param1: category)..add(SeeMoreFetched()),
    child: Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<SeeMoreBloc, SeeMoreState>(builder: _body),
    ),
  );

  Widget _body(BuildContext context, SeeMoreState state) {
    final bloc = context.read<SeeMoreBloc>();

    if (state.items.isEmpty) {
      return switch (state.status) {
        RequestState.failed => CustomErrorItem(
          message: state.message,
          onRetry: () => bloc.add(SeeMoreFetched()),
        ),
        RequestState.success => const Center(child: Text('Nothing found')),
        _ => const CustomLoadingAnimation(
          isLoading: true,
          barrierColor: Colors.transparent,
          child: SizedBox.expand(),
        ),
      };
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, viewportConstraints) => RefreshIndicator(
          onRefresh: () async => bloc.add(SeeMoreFetched()),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.extentAfter < 400) {
                bloc.add(SeeMoreNextPageRequested());
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(
                  children: [
                    for (final item in state.items) SeeMoreTile(item),
                    _footerLoading(state, bloc),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerLoading(SeeMoreState state, SeeMoreBloc bloc) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Center(
      child: switch (state.status) {
        RequestState.loading => const CircularProgressIndicator(),
        RequestState.failed => TextButton(
          onPressed: () => bloc.add(SeeMoreNextPageRequested()),
          child: Text('${state.message} — tap to retry'),
        ),
        _ => const SizedBox.shrink(),
      },
    ),
  );
}

part of '../see_more.dart';

class SeeMoreTile extends StatelessWidget {
  final MediaItem item;
  const SeeMoreTile(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    void open() => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => switch (item.type) {
          MediaType.movie => DetailMovieView(id: item.id),
          MediaType.tv => TvDetailView(id: item.id),
        },
      ),
    );

    return InkWell(
      onTap: open,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: PosterCard(
                posterPath: item.posterPath,
                width: 80,
                onTap: open,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (item.overview ?? '').isEmpty
                        ? 'No description.'
                        : item.overview!,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

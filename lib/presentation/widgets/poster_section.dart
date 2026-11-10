part of 'widgets.dart';

class PosterSection extends StatelessWidget {
  final String title;
  final List<String?> posterPaths;
  final VoidCallback onSeeMore;
  final ValueChanged<int> onTap;

  const PosterSection({
    super.key,
    required this.title,
    required this.posterPaths,
    required this.onSeeMore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          CustomTextButton(title: 'See More', onPressed: onSeeMore),
        ],
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: posterPaths.length,
          itemBuilder: (context, i) =>
              PosterCard(posterPath: posterPaths[i], onTap: () => onTap(i)),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

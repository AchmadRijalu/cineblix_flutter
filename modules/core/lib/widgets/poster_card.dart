part of 'widgets.dart';

class PosterCard extends StatelessWidget {
  final String? posterPath;
  final VoidCallback? onTap;
  final double width;
  const PosterCard({
    super.key,
    required this.posterPath,
    this.onTap,
    this.width = 100,
  });

  Widget _placeholder() =>
      SizedBox(width: width, child: const Icon(Icons.movie));

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: posterPath == null
            ? _placeholder()
            : Image.network(
                '$imageBaseUrl$posterPath',
                width: width,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              ),
      ),
    ),
  );
}

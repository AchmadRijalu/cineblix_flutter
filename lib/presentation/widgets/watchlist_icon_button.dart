part of 'widgets.dart';

class WatchlistIconButton extends StatelessWidget {
  final bool isAdded;
  final VoidCallback onPressed;
  const WatchlistIconButton({
    super.key,
    required this.isAdded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: isAdded ? 'Remove from Watchlist' : 'Add to Watchlist',
    icon: Icon(isAdded ? Icons.favorite : Icons.favorite_border),
    color: isAdded ? Colors.red : null,
    onPressed: onPressed,
  );
}

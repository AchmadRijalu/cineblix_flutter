part of 'entities.dart';

class MediaPage extends Equatable {
  final List<MediaItem> items;
  final int page;
  final int totalPages;

  const MediaPage({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  @override
  List<Object> get props => [items, page, totalPages];
}

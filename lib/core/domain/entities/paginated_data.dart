class PaginatedData<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int totalDocs;
  final int totalPages;

  const PaginatedData({
    required this.items,
    required this.page,
    required this.limit,
    required this.totalDocs,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
}

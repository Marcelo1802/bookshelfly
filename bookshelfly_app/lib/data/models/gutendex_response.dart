import 'gutendex_book_model.dart';

class GutendexResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<GutendexBookModel> results;

  const GutendexResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory GutendexResponse.fromJson(Map<String, dynamic> json) {
    return GutendexResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((book) => GutendexBookModel.fromJson(book))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((book) => book.toJson()).toList(),
    };
  }
}

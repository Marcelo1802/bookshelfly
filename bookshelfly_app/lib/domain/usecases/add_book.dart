import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../repositories/book_repository.dart';
import '../../core/errors/failures.dart';

class SearchBooks {
  final BookRepository repository;

  SearchBooks(this.repository);

  Future<Either<Failure, List<GutendexBook>>> call(String query, {int page = 1, int pageSize = 32}) async {
    return await repository.searchBooks(query, page: page, pageSize: pageSize);
  }
}

import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../../core/errors/failures.dart';

abstract class BookRepository {
  Future<Either<Failure, List<GutendexBook>>> getBooks({int page = 1, int pageSize = 32});
  Future<Either<Failure, GutendexBook>> getBookById(int id);
  Future<Either<Failure, List<GutendexBook>>> searchBooks(String query, {int page = 1, int pageSize = 32});
}

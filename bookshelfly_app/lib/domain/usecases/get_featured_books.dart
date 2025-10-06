import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../../core/errors/failures.dart';
import '../repositories/book_repository.dart';

class GetFeaturedBooks {
  final BookRepository repository;

  GetFeaturedBooks(this.repository);

  Future<Either<Failure, List<GutendexBook>>> call() async {
    return await repository.getBooks(page: 1, pageSize: 5);
  }
}

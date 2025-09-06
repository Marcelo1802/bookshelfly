import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../repositories/book_repository.dart';
import '../../core/errors/failures.dart';

class GetBooks {
  final BookRepository repository;

  GetBooks(this.repository);

  Future<Either<Failure, List<GutendexBook>>> call({int page = 1, int pageSize = 32}) async {
    return await repository.getBooks(page: page, pageSize: pageSize);
  }
}

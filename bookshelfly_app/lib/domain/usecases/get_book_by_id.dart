import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../repositories/book_repository.dart';
import '../../core/errors/failures.dart';

class GetBookById {
  final BookRepository repository;

  GetBookById(this.repository);

  Future<Either<Failure, GutendexBook>> call(int id) async {
    return await repository.getBookById(id);
  }
}

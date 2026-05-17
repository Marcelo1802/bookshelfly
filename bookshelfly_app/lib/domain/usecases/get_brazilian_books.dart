import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../repositories/book_repository.dart';
import '../../core/errors/failures.dart';

class GetBrazilianBooks {
  final BookRepository repository;

  GetBrazilianBooks(this.repository);

  Future<Either<Failure, List<GutendexBook>>> call() async {
    // Mantemos uma busca única para a home carregar rapidamente na web.
    final result = await repository.searchBooks(
      'Machado de Assis',
      page: 1,
      pageSize: 8,
    );

    return result.fold(
      (failure) => Left(failure),
      (books) {
        if (books.isEmpty) {
          return Left(CacheFailure('Nenhum livro brasileiro encontrado'));
        }

        return Right(books.take(8).toList());
      },
    );
  }
}

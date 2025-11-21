import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../repositories/book_repository.dart';
import '../../core/errors/failures.dart';

class GetBrazilianBooks {
  final BookRepository repository;

  GetBrazilianBooks(this.repository);

  Future<Either<Failure, List<GutendexBook>>> call() async {
    // Buscar por autores brasileiros famosos
    final brazilianAuthors = [
      'Machado de Assis',
      'Paulo Coelho',
      'Jorge Amado',
      'Clarice Lispector',
      'Guimarães Rosa',
      'Cecília Meireles',
      'Carlos Drummond de Andrade',
      'Monteiro Lobato',
      'Lima Barreto',
      'Graciliano Ramos',
    ];

    List<GutendexBook> allBrazilianBooks = [];

    // Buscar livros de cada autor brasileiro
    for (final author in brazilianAuthors) {
      final result = await repository.searchBooks(author, page: 1, pageSize: 10);
      result.fold(
        (failure) => null, // Ignorar falhas individuais
        (books) => allBrazilianBooks.addAll(books),
      );
      
      // Limitar a 10 livros no total
      if (allBrazilianBooks.length >= 10) {
        break;
      }
    }

    // Se não encontrou nenhum livro brasileiro, retornar erro
    if (allBrazilianBooks.isEmpty) {
      return Left(CacheFailure('Nenhum livro brasileiro encontrado'));
    }

    // Retornar apenas os 10 primeiros
    return Right(allBrazilianBooks.take(10).toList());
  }
}


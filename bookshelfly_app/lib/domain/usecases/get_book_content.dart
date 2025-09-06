import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/book_content_repository.dart';

class GetBookContent {
  final BookContentRepository repository;

  GetBookContent(this.repository);

  Future<Either<Failure, String>> call(int bookId, String url) async {
    // Primeiro, tentar buscar do cache
    final cachedResult = await repository.getCachedBookContent(bookId);
    return cachedResult.fold(
      (failure) async {
        // Se não encontrar no cache, baixar da internet
        final contentResult = await repository.getBookContent(url);
        return contentResult.fold(
          (failure) => Left(failure),
          (content) async {
            // Salvar no cache para próximas leituras
            final cacheResult = await repository.cacheBookContent(bookId, content);
            return cacheResult.fold(
              (failure) => Right(content), // Retorna o conteúdo mesmo se falhar ao salvar
              (_) => Right(content),
            );
          },
        );
      },
      (cachedContent) => Right(cachedContent),
    );
  }
}

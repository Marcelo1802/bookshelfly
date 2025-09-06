import 'package:dartz/dartz.dart';
import '../../domain/repositories/book_content_repository.dart';
import '../datasources/book_content_datasource.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

class BookContentRepositoryImpl implements BookContentRepository {
  final BookContentDataSource dataSource;

  BookContentRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, String>> getBookContent(String url) async {
    try {
      final content = await dataSource.getBookContent(url);
      return Right(content);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getCachedBookContent(int bookId) async {
    try {
      final content = await dataSource.getCachedBookContent(bookId);
      return Right(content);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheBookContent(int bookId, String content) async {
    try {
      await dataSource.cacheBookContent(bookId, content);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }
}

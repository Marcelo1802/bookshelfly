import 'package:dartz/dartz.dart';
import '../../domain/entities/gutendex_book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/gutendex_remote_datasource.dart';
import '../datasources/gutendex_local_datasource.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

class BookRepositoryImpl implements BookRepository {
  final GutendexRemoteDataSource remoteDataSource;
  final GutendexLocalDataSource localDataSource;

  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<GutendexBook>>> getBooks({int page = 1, int pageSize = 32}) async {
    try {
      // Tentar buscar no cache primeiro
      final cachedResponse = await localDataSource.getCachedBooks(page: page, pageSize: pageSize);
      if (cachedResponse != null) {
        return Right(cachedResponse.results);
      }

      // Se não há cache, buscar na API
      final response = await remoteDataSource.getBooks(page: page, pageSize: pageSize);
      
      // Salvar no cache para próximas consultas
      await localDataSource.cacheBooks(response, page: page, pageSize: pageSize);
      
      return Right(response.results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Se falhar a rede, tentar usar cache mesmo que expirado
      try {
        final cachedResponse = await localDataSource.getCachedBooks(page: page, pageSize: pageSize);
        if (cachedResponse != null) {
          return Right(cachedResponse.results);
        }
      } catch (_) {
        // Ignorar erros de cache
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, GutendexBook>> getBookById(int id) async {
    try {
      // Tentar buscar no cache primeiro
      final cachedBook = await localDataSource.getCachedBookById(id);
      if (cachedBook != null) {
        return Right(cachedBook);
      }

      // Se não há cache, buscar na API
      final book = await remoteDataSource.getBookById(id);
      
      // Salvar no cache para próximas consultas
      await localDataSource.cacheBook(book);
      
      return Right(book);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Se falhar a rede, tentar usar cache mesmo que expirado
      try {
        final cachedBook = await localDataSource.getCachedBookById(id);
        if (cachedBook != null) {
          return Right(cachedBook);
        }
      } catch (_) {
        // Ignorar erros de cache
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GutendexBook>>> searchBooks(String query, {int page = 1, int pageSize = 32}) async {
    try {
      // Tentar buscar no cache primeiro
      final cachedResponse = await localDataSource.getCachedSearchResults(query, page: page, pageSize: pageSize);
      if (cachedResponse != null) {
        return Right(cachedResponse.results);
      }

      // Se não há cache, buscar na API
      final response = await remoteDataSource.searchBooks(query, page: page, pageSize: pageSize);
      
      // Salvar no cache para próximas consultas
      await localDataSource.cacheSearchResults(query, response, page: page, pageSize: pageSize);
      
      return Right(response.results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Se falhar a rede, tentar usar cache mesmo que expirado
      try {
        final cachedResponse = await localDataSource.getCachedSearchResults(query, page: page, pageSize: pageSize);
        if (cachedResponse != null) {
          return Right(cachedResponse.results);
        }
      } catch (_) {
        // Ignorar erros de cache
      }
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }
}

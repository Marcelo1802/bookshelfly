import 'package:dartz/dartz.dart';
import '../../domain/entities/gutendex_book.dart';
import '../../domain/repositories/banner_repository.dart';
import '../datasources/banner_cache_datasource.dart';
import '../datasources/gutendex_remote_datasource.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

class BannerRepositoryImpl implements BannerRepository {
  final GutendexRemoteDataSource remoteDataSource;
  final BannerCacheDataSource cacheDataSource;

  BannerRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheDataSource,
  });

  @override
  Future<Either<Failure, List<GutendexBook>>> getFeaturedBooks() async {
    try {
      // Tentar buscar no cache primeiro
      final cachedBooks = await cacheDataSource.getCachedFeaturedBooks();
      if (cachedBooks != null && cachedBooks.isNotEmpty) {
        // Converter GutendexBookModel para GutendexBook (já são compatíveis)
        return Right(cachedBooks);
      }

      // Se não há cache, buscar na API
      final response = await remoteDataSource.getBooks(page: 1, pageSize: 5);
      
      // Salvar no cache para próximas consultas
      await cacheDataSource.cacheFeaturedBooks(response.results);
      
      return Right(response.results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      // Se falhar a rede, tentar usar cache mesmo que expirado
      try {
        final cachedBooks = await cacheDataSource.getCachedFeaturedBooks();
        if (cachedBooks != null) {
          return Right(cachedBooks);
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
  Future<List<GutendexBook>> getCachedFeaturedBooksImmediate() async {
    try {
      // Buscar cache imediatamente, mesmo que expirado (para exibição instantânea)
      final cachedBooks = await cacheDataSource.getCachedFeaturedBooksIgnoreValidity();
      return cachedBooks ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<Either<Failure, void>> clearBannerCache() async {
    try {
      await cacheDataSource.clearBannerCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }
}

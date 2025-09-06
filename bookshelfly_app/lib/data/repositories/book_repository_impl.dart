import 'package:dartz/dartz.dart';
import '../../domain/entities/gutendex_book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/gutendex_remote_datasource.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';

class BookRepositoryImpl implements BookRepository {
  final GutendexRemoteDataSource remoteDataSource;

  BookRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<GutendexBook>>> getBooks({int page = 1, int pageSize = 32}) async {
    try {
      final response = await remoteDataSource.getBooks(page: page, pageSize: pageSize);
      return Right(response.results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, GutendexBook>> getBookById(int id) async {
    try {
      final book = await remoteDataSource.getBookById(id);
      return Right(book);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GutendexBook>>> searchBooks(String query, {int page = 1, int pageSize = 32}) async {
    try {
      final response = await remoteDataSource.searchBooks(query, page: page, pageSize: pageSize);
      return Right(response.results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro desconhecido: $e'));
    }
  }
}

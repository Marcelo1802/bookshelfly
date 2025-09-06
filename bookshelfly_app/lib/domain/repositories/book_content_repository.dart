import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

abstract class BookContentRepository {
  Future<Either<Failure, String>> getBookContent(String url);
  Future<Either<Failure, String>> getCachedBookContent(int bookId);
  Future<Either<Failure, void>> cacheBookContent(int bookId, String content);
}

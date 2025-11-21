import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../../core/errors/failures.dart';

abstract class BannerRepository {
  Future<Either<Failure, List<GutendexBook>>> getFeaturedBooks();
  Future<List<GutendexBook>> getCachedFeaturedBooksImmediate();
  Future<Either<Failure, void>> clearBannerCache();
}


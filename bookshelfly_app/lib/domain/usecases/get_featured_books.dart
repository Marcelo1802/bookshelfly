import 'package:dartz/dartz.dart';
import '../entities/gutendex_book.dart';
import '../../core/errors/failures.dart';
import '../repositories/banner_repository.dart';

class GetFeaturedBooks {
  final BannerRepository repository;

  GetFeaturedBooks(this.repository);

  Future<Either<Failure, List<GutendexBook>>> call() async {
    return await repository.getFeaturedBooks();
  }
}

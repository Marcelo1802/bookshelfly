import 'package:dartz/dartz.dart';
import '../repositories/book_repository.dart';
import '../../core/errors/failures.dart';

class ClearCache {
  final BookRepository repository;

  ClearCache(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearCache();
  }
}

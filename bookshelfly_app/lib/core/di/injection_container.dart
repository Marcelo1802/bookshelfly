import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/gutendex_remote_datasource.dart';
import '../../data/datasources/book_content_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../data/repositories/book_content_repository_impl.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/book_content_repository.dart';
import '../../domain/usecases/get_all_books.dart';
import '../../domain/usecases/add_book.dart';
import '../../domain/usecases/get_book_by_id.dart';
import '../../domain/usecases/get_book_content.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => http.Client());
  
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Data sources
  sl.registerLazySingleton<GutendexRemoteDataSource>(
    () => GutendexRemoteDataSourceImpl(client: sl()),
  );
  
  sl.registerLazySingleton<BookContentDataSource>(
    () => BookContentDataSourceImpl(client: sl()),
  );

  // Repository
  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<BookContentRepository>(
    () => BookContentRepositoryImpl(dataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBooks(sl()));
  sl.registerLazySingleton(() => SearchBooks(sl()));
  sl.registerLazySingleton(() => GetBookById(sl()));
  sl.registerLazySingleton(() => GetBookContent(sl()));
}

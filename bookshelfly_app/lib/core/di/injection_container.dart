import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/gutendex_remote_datasource.dart';
import '../../data/datasources/gutendex_local_datasource.dart';
import '../../data/datasources/banner_cache_datasource.dart';
import '../../data/datasources/user_books_datasource.dart';
import '../../data/datasources/notes_datasource.dart';
import '../../data/datasources/book_content_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../data/repositories/book_content_repository_impl.dart';
import '../../data/repositories/banner_repository_impl.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/book_content_repository.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../domain/usecases/get_all_books.dart';
import '../../domain/usecases/add_book.dart';
import '../../domain/usecases/get_book_by_id.dart';
import '../../domain/usecases/get_book_content.dart';
import '../../domain/usecases/get_featured_books.dart';
import '../../domain/usecases/get_brazilian_books.dart';
import '../../domain/usecases/clear_cache.dart';

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
  
  sl.registerLazySingleton<GutendexLocalDataSource>(
    () => GutendexLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  sl.registerLazySingleton<BannerCacheDataSource>(
    () => BannerCacheDataSourceImpl(sharedPreferences: sl()),
  );
  
  sl.registerLazySingleton<UserBooksDataSource>(
    () => UserBooksDataSourceImpl(sharedPreferences: sl()),
  );
  
  sl.registerLazySingleton<NotesDataSource>(
    () => NotesDataSourceImpl(sharedPreferences: sl()),
  );
  
  sl.registerLazySingleton<BookContentDataSource>(
    () => BookContentDataSourceImpl(client: sl()),
  );

  // Repository
  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  sl.registerLazySingleton<BookContentRepository>(
    () => BookContentRepositoryImpl(dataSource: sl()),
  );
  
  sl.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(
      remoteDataSource: sl(),
      cacheDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBooks(sl()));
  sl.registerLazySingleton(() => SearchBooks(sl()));
  sl.registerLazySingleton(() => GetBookById(sl()));
  sl.registerLazySingleton(() => GetBookContent(sl()));
  sl.registerLazySingleton(() => GetFeaturedBooks(sl()));
  sl.registerLazySingleton(() => GetBrazilianBooks(sl()));
  sl.registerLazySingleton(() => ClearCache(sl()));
}

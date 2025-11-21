import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart';
import 'presentation/viewmodels/books_viewmodel.dart';
import 'presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const BookShelflyApp());
}

class BookShelflyApp extends StatelessWidget {
  const BookShelflyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BooksViewModel(
            getBooks: sl(),
            searchBooks: sl(),
            getBookById: sl(),
            getFeaturedBooks: sl(),
            getBrazilianBooks: sl(),
            bannerRepository: sl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'BookShelfly',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.white,
            elevation: 0,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
        ),
        home: const MainPage(),
      ),
    );
  }
}

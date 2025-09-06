import 'package:flutter/foundation.dart';
import '../../domain/entities/gutendex_book.dart';
import '../../domain/usecases/get_all_books.dart';
import '../../domain/usecases/add_book.dart';
import '../../domain/usecases/get_book_by_id.dart';
import '../../core/errors/failures.dart';

class BooksViewModel extends ChangeNotifier {
  final GetBooks getBooks;
  final SearchBooks searchBooks;
  final GetBookById getBookById;

  BooksViewModel({
    required this.getBooks,
    required this.searchBooks,
    required this.getBookById,
  });

  List<GutendexBook> _books = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int _currentPage = 1;
  bool _hasMoreBooks = true;

  List<GutendexBook> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasMoreBooks => _hasMoreBooks;

  Future<void> loadBooks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _books.clear();
      _hasMoreBooks = true;
    }

    if (!_hasMoreBooks) return;

    _setLoading(true);
    _clearError();

    final result = await getBooks(page: _currentPage);
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (newBooks) {
        if (refresh) {
          _books = newBooks;
        } else {
          _books.addAll(newBooks);
        }
        
        if (newBooks.length < 32) {
          _hasMoreBooks = false;
        } else {
          _currentPage++;
        }
        
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      _searchQuery = '';
      await loadBooks(refresh: true);
      return;
    }

    _searchQuery = query;
    _currentPage = 1;
    _books.clear();
    _hasMoreBooks = true;

    _setLoading(true);
    _clearError();

    final result = await searchBooks(query, page: _currentPage);
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (searchResults) {
        _books = searchResults;
        if (searchResults.length < 32) {
          _hasMoreBooks = false;
        } else {
          _currentPage++;
        }
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  Future<void> loadMoreBooks() async {
    if (_isLoading || !_hasMoreBooks) return;

    if (_searchQuery.isNotEmpty) {
      final result = await searchBooks(_searchQuery, page: _currentPage);
      result.fold(
        (failure) => _setError(_mapFailureToMessage(failure)),
        (newBooks) {
          _books.addAll(newBooks);
          if (newBooks.length < 32) {
            _hasMoreBooks = false;
          } else {
            _currentPage++;
          }
          notifyListeners();
        },
      );
    } else {
      await loadBooks();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Erro no servidor. Tente novamente.';
      case NetworkFailure _:
        return 'Erro de conexão. Verifique sua internet.';
      case CacheFailure _:
        return 'Erro no armazenamento local.';
      case ValidationFailure _:
        return 'Dados inválidos.';
      default:
        return 'Erro desconhecido.';
    }
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gutendex_book_model.dart';
import '../../core/errors/exceptions.dart';

abstract class UserBooksDataSource {
  Future<List<GutendexBookModel>> getFavoriteBooks();
  Future<List<GutendexBookModel>> getReadingBooks();
  Future<void> addFavoriteBook(GutendexBookModel book);
  Future<void> removeFavoriteBook(int bookId);
  Future<void> addReadingBook(GutendexBookModel book);
  Future<void> removeReadingBook(int bookId);
  Future<bool> isFavoriteBook(int bookId);
  Future<bool> isReadingBook(int bookId);
}

class UserBooksDataSourceImpl implements UserBooksDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _favoritesKey = 'user_favorite_books';
  static const String _readingKey = 'user_reading_books';

  UserBooksDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<GutendexBookModel>> getFavoriteBooks() async {
    try {
      final favoritesJson = sharedPreferences.getString(_favoritesKey);
      if (favoritesJson == null) return [];
      
      final List<dynamic> jsonList = json.decode(favoritesJson);
      final List<GutendexBookModel> books = [];
      
      for (final item in jsonList) {
        try {
          if (item is Map<String, dynamic>) {
            books.add(GutendexBookModel.fromJson(item));
          }
        } catch (e) {
          // Ignorar itens inválidos e continuar
          continue;
        }
      }
      
      return books;
    } catch (e) {
      // Se houver erro, retornar lista vazia em vez de lançar exceção
      return [];
    }
  }

  @override
  Future<List<GutendexBookModel>> getReadingBooks() async {
    try {
      final readingJson = sharedPreferences.getString(_readingKey);
      if (readingJson == null) return [];
      
      final List<dynamic> jsonList = json.decode(readingJson);
      final List<GutendexBookModel> books = [];
      
      for (final item in jsonList) {
        try {
          if (item is Map<String, dynamic>) {
            books.add(GutendexBookModel.fromJson(item));
          }
        } catch (e) {
          // Ignorar itens inválidos e continuar
          continue;
        }
      }
      
      return books;
    } catch (e) {
      // Se houver erro, retornar lista vazia em vez de lançar exceção
      return [];
    }
  }

  @override
  Future<void> addFavoriteBook(GutendexBookModel book) async {
    try {
      final favorites = await getFavoriteBooks();
      
      // Verificar se já existe
      if (favorites.any((b) => b.id == book.id)) {
        return; // Já está nos favoritos
      }
      
      favorites.add(book);
      final jsonList = <Map<String, dynamic>>[];
      for (final b in favorites) {
        try {
          jsonList.add(b.toJson());
        } catch (e) {
          // Ignorar livros com erro ao serializar
        }
      }
      
      await sharedPreferences.setString(_favoritesKey, json.encode(jsonList));
    } catch (e) {
      // Ignorar erros silenciosamente para não quebrar a aplicação
    }
  }

  @override
  Future<void> removeFavoriteBook(int bookId) async {
    try {
      final favorites = await getFavoriteBooks();
      favorites.removeWhere((book) => book.id == bookId);
      
      final jsonList = <Map<String, dynamic>>[];
      for (final b in favorites) {
        try {
          jsonList.add(b.toJson());
        } catch (e) {
          // Ignorar livros com erro ao serializar
        }
      }
      
      await sharedPreferences.setString(_favoritesKey, json.encode(jsonList));
    } catch (e) {
      // Ignorar erros silenciosamente
    }
  }

  @override
  Future<void> addReadingBook(GutendexBookModel book) async {
    try {
      final reading = await getReadingBooks();
      
      // Verificar se já existe
      if (reading.any((b) => b.id == book.id)) {
        return; // Já está em leitura
      }
      
      reading.add(book);
      final jsonList = <Map<String, dynamic>>[];
      for (final b in reading) {
        try {
          jsonList.add(b.toJson());
        } catch (e) {
          // Ignorar livros com erro ao serializar
        }
      }
      
      await sharedPreferences.setString(_readingKey, json.encode(jsonList));
    } catch (e) {
      // Ignorar erros silenciosamente para não quebrar a aplicação
    }
  }

  @override
  Future<void> removeReadingBook(int bookId) async {
    try {
      final reading = await getReadingBooks();
      reading.removeWhere((book) => book.id == bookId);
      
      final jsonList = <Map<String, dynamic>>[];
      for (final b in reading) {
        try {
          jsonList.add(b.toJson());
        } catch (e) {
          // Ignorar livros com erro ao serializar
        }
      }
      
      await sharedPreferences.setString(_readingKey, json.encode(jsonList));
    } catch (e) {
      // Ignorar erros silenciosamente
    }
  }

  @override
  Future<bool> isFavoriteBook(int bookId) async {
    try {
      final favorites = await getFavoriteBooks();
      return favorites.any((book) => book.id == bookId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isReadingBook(int bookId) async {
    try {
      final reading = await getReadingBooks();
      return reading.any((book) => book.id == bookId);
    } catch (e) {
      return false;
    }
  }
}


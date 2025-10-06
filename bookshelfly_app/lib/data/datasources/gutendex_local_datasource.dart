import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gutendex_response.dart';
import '../models/gutendex_book_model.dart';
import '../../core/errors/exceptions.dart';

abstract class GutendexLocalDataSource {
  Future<GutendexResponse?> getCachedBooks({int page = 1, int pageSize = 32});
  Future<GutendexResponse?> getCachedSearchResults(String query, {int page = 1, int pageSize = 32});
  Future<GutendexBookModel?> getCachedBookById(int id);
  Future<void> cacheBooks(GutendexResponse response, {int page = 1, int pageSize = 32});
  Future<void> cacheSearchResults(String query, GutendexResponse response, {int page = 1, int pageSize = 32});
  Future<void> cacheBook(GutendexBookModel book);
  Future<void> clearCache();
  Future<bool> isCacheValid(String key, {Duration maxAge = const Duration(hours: 1)});
}

class GutendexLocalDataSourceImpl implements GutendexLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _booksCachePrefix = 'books_cache_';
  static const String _searchCachePrefix = 'search_cache_';
  static const String _bookCachePrefix = 'book_cache_';
  static const String _timestampSuffix = '_timestamp';

  GutendexLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<GutendexResponse?> getCachedBooks({int page = 1, int pageSize = 32}) async {
    try {
      final key = '$_booksCachePrefix${page}_$pageSize';
      final timestampKey = '$key$_timestampSuffix';
      
      // Verificar se o cache é válido
      if (!await isCacheValid(timestampKey)) {
        return null;
      }
      
      final cachedData = sharedPreferences.getString(key);
      if (cachedData != null) {
        final jsonData = json.decode(cachedData);
        return GutendexResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      throw CacheException('Erro ao ler cache de livros: $e');
    }
  }

  @override
  Future<GutendexResponse?> getCachedSearchResults(String query, {int page = 1, int pageSize = 32}) async {
    try {
      final key = '$_searchCachePrefix${_encodeQuery(query)}_${page}_$pageSize';
      final timestampKey = '$key$_timestampSuffix';
      
      // Verificar se o cache é válido
      if (!await isCacheValid(timestampKey)) {
        return null;
      }
      
      final cachedData = sharedPreferences.getString(key);
      if (cachedData != null) {
        final jsonData = json.decode(cachedData);
        return GutendexResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      throw CacheException('Erro ao ler cache de busca: $e');
    }
  }

  @override
  Future<GutendexBookModel?> getCachedBookById(int id) async {
    try {
      final key = '$_bookCachePrefix$id';
      final timestampKey = '$key$_timestampSuffix';
      
      // Verificar se o cache é válido
      if (!await isCacheValid(timestampKey)) {
        return null;
      }
      
      final cachedData = sharedPreferences.getString(key);
      if (cachedData != null) {
        final jsonData = json.decode(cachedData);
        return GutendexBookModel.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      throw CacheException('Erro ao ler cache do livro: $e');
    }
  }

  @override
  Future<void> cacheBooks(GutendexResponse response, {int page = 1, int pageSize = 32}) async {
    try {
      final key = '$_booksCachePrefix${page}_$pageSize';
      final timestampKey = '$key$_timestampSuffix';
      
      await sharedPreferences.setString(key, json.encode(response.toJson()));
      await sharedPreferences.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw CacheException('Erro ao salvar cache de livros: $e');
    }
  }

  @override
  Future<void> cacheSearchResults(String query, GutendexResponse response, {int page = 1, int pageSize = 32}) async {
    try {
      final key = '$_searchCachePrefix${_encodeQuery(query)}_${page}_$pageSize';
      final timestampKey = '$key$_timestampSuffix';
      
      await sharedPreferences.setString(key, json.encode(response.toJson()));
      await sharedPreferences.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw CacheException('Erro ao salvar cache de busca: $e');
    }
  }

  @override
  Future<void> cacheBook(GutendexBookModel book) async {
    try {
      final key = '$_bookCachePrefix${book.id}';
      final timestampKey = '$key$_timestampSuffix';
      
      await sharedPreferences.setString(key, json.encode(book.toJson()));
      await sharedPreferences.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw CacheException('Erro ao salvar cache do livro: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final keys = sharedPreferences.getKeys();
      final cacheKeys = keys.where((key) => 
        key.startsWith(_booksCachePrefix) || 
        key.startsWith(_searchCachePrefix) || 
        key.startsWith(_bookCachePrefix)
      ).toList();
      
      for (final key in cacheKeys) {
        await sharedPreferences.remove(key);
      }
    } catch (e) {
      throw CacheException('Erro ao limpar cache: $e');
    }
  }

  @override
  Future<bool> isCacheValid(String key, {Duration maxAge = const Duration(hours: 1)}) async {
    try {
      final timestamp = sharedPreferences.getInt(key);
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) < maxAge;
    } catch (e) {
      return false;
    }
  }

  String _encodeQuery(String query) {
    // Codificar a query para usar como chave no cache
    return query.replaceAll(' ', '_').toLowerCase();
  }
}

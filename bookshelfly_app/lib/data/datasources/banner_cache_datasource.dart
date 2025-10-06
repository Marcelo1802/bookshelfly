import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gutendex_book_model.dart';
import '../../core/errors/exceptions.dart';

abstract class BannerCacheDataSource {
  Future<List<GutendexBookModel>?> getCachedFeaturedBooks();
  Future<void> cacheFeaturedBooks(List<GutendexBookModel> books);
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 2)});
  Future<void> clearBannerCache();
}

class BannerCacheDataSourceImpl implements BannerCacheDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _bannerCacheKey = 'banner_featured_books';
  static const String _bannerTimestampKey = 'banner_cache_timestamp';

  BannerCacheDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<GutendexBookModel>?> getCachedFeaturedBooks() async {
    try {
      // Verificar se o cache é válido
      if (!await isCacheValid()) {
        return null;
      }
      
      final cachedData = sharedPreferences.getString(_bannerCacheKey);
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((json) => GutendexBookModel.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Erro ao ler cache do banner: $e');
    }
  }

  @override
  Future<void> cacheFeaturedBooks(List<GutendexBookModel> books) async {
    try {
      // Pegar apenas os primeiros 5 livros para o banner
      final booksToCache = books.take(5).toList();
      
      final jsonList = booksToCache.map((book) => book.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      await sharedPreferences.setString(_bannerCacheKey, jsonString);
      await sharedPreferences.setInt(_bannerTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw CacheException('Erro ao salvar cache do banner: $e');
    }
  }

  @override
  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 2)}) async {
    try {
      final timestamp = sharedPreferences.getInt(_bannerTimestampKey);
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) < maxAge;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearBannerCache() async {
    try {
      await sharedPreferences.remove(_bannerCacheKey);
      await sharedPreferences.remove(_bannerTimestampKey);
    } catch (e) {
      throw CacheException('Erro ao limpar cache do banner: $e');
    }
  }
}

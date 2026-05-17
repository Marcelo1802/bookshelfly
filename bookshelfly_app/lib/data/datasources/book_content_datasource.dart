import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/web_url_proxy.dart';

abstract class BookContentDataSource {
  Future<String> getBookContent(String url);
  Future<String> getCachedBookContent(int bookId);
  Future<void> cacheBookContent(int bookId, String content);
}

class BookContentDataSourceImpl implements BookContentDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;
  static const String _cachePrefix = 'book_content_';

  BookContentDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<String> getBookContent(String url) async {
    try {
      final response = await client.get(Uri.parse(proxiedWebUrl(url)));
      
      if (response.statusCode == 200) {
        // Tentar decodificar como UTF-8 primeiro
        try {
          return utf8.decode(response.bodyBytes);
        } catch (e) {
          // Se falhar, tentar como latin-1
          return latin1.decode(response.bodyBytes);
        }
      } else {
        throw ServerException('Erro ao baixar conteúdo do livro: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Erro de conexão: $e');
    }
  }

  @override
  Future<String> getCachedBookContent(int bookId) async {
    try {
      final cachedContent = sharedPreferences.getString(
        '$_cachePrefix$bookId',
      );

      if (cachedContent != null && cachedContent.isNotEmpty) {
        return cachedContent;
      }

      throw CacheException('Conteúdo do livro não encontrado no cache');
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Erro ao ler cache: $e');
    }
  }

  @override
  Future<void> cacheBookContent(int bookId, String content) async {
    try {
      await sharedPreferences.setString('$_cachePrefix$bookId', content);
    } catch (e) {
      throw CacheException('Erro ao salvar cache: $e');
    }
  }
}

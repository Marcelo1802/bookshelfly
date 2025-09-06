import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../core/errors/exceptions.dart';

abstract class BookContentDataSource {
  Future<String> getBookContent(String url);
  Future<String> getCachedBookContent(int bookId);
  Future<void> cacheBookContent(int bookId, String content);
}

class BookContentDataSourceImpl implements BookContentDataSource {
  final http.Client client;
  static const String _cachePrefix = 'book_content_';

  BookContentDataSourceImpl({required this.client});

  @override
  Future<String> getBookContent(String url) async {
    try {
      final response = await client.get(Uri.parse(url));
      
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
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cachePrefix$bookId.txt');
      
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        throw CacheException('Conteúdo do livro não encontrado no cache');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Erro ao ler cache: $e');
    }
  }

  @override
  Future<void> cacheBookContent(int bookId, String content) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cachePrefix$bookId.txt');
      await file.writeAsString(content);
    } catch (e) {
      throw CacheException('Erro ao salvar cache: $e');
    }
  }
}

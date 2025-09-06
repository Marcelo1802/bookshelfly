import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gutendex_response.dart';
import '../models/gutendex_book_model.dart';
import '../../core/errors/exceptions.dart';

abstract class GutendexRemoteDataSource {
  Future<GutendexResponse> getBooks({int page = 1, int pageSize = 32});
  Future<GutendexResponse> searchBooks(String query, {int page = 1, int pageSize = 32});
  Future<GutendexBookModel> getBookById(int id);
}

class GutendexRemoteDataSourceImpl implements GutendexRemoteDataSource {
  final http.Client client;
  static const String _baseUrl = 'https://gutendex.com';

  GutendexRemoteDataSourceImpl({required this.client});

  @override
  Future<GutendexResponse> getBooks({int page = 1, int pageSize = 32}) async {
    try {
      final uri = Uri.parse('$_baseUrl/books/?page=$page&page_size=$pageSize');
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return GutendexResponse.fromJson(jsonData);
      } else {
        throw ServerException('Erro ao buscar livros: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Erro de conexão: $e');
    }
  }

  @override
  Future<GutendexResponse> searchBooks(String query, {int page = 1, int pageSize = 32}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final uri = Uri.parse('$_baseUrl/books/?search=$encodedQuery&page=$page&page_size=$pageSize');
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return GutendexResponse.fromJson(jsonData);
      } else {
        throw ServerException('Erro ao buscar livros: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Erro de conexão: $e');
    }
  }

  @override
  Future<GutendexBookModel> getBookById(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/books/$id/');
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return GutendexBookModel.fromJson(jsonData);
      } else {
        throw ServerException('Erro ao buscar livro: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Erro de conexão: $e');
    }
  }
}

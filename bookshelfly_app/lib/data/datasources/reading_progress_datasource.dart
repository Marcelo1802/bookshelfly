import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';

class ReadingProgress {
  final int bookId;
  final int currentPage;
  final int totalPages;
  final DateTime lastRead;
  final double fontSize;
  final double lineHeight;
  final bool isDarkMode;

  const ReadingProgress({
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
    required this.lastRead,
    required this.fontSize,
    required this.lineHeight,
    required this.isDarkMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'lastRead': lastRead.toIso8601String(),
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'isDarkMode': isDarkMode,
    };
  }

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      bookId: json['bookId'] as int,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      lastRead: DateTime.parse(json['lastRead'] as String),
      fontSize: (json['fontSize'] as num).toDouble(),
      lineHeight: (json['lineHeight'] as num).toDouble(),
      isDarkMode: json['isDarkMode'] as bool,
    );
  }
}

abstract class ReadingProgressDataSource {
  Future<ReadingProgress?> getReadingProgress(int bookId);
  Future<void> saveReadingProgress(ReadingProgress progress);
  Future<void> deleteReadingProgress(int bookId);
}

class ReadingProgressDataSourceImpl implements ReadingProgressDataSource {
  final SharedPreferences sharedPreferences;
  static const String _progressKey = 'reading_progress_';

  ReadingProgressDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ReadingProgress?> getReadingProgress(int bookId) async {
    try {
      final progressJson = sharedPreferences.getString('$_progressKey$bookId');
      if (progressJson != null) {
        final progressMap = json.decode(progressJson) as Map<String, dynamic>;
        return ReadingProgress.fromJson(progressMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Erro ao carregar progresso de leitura: $e');
    }
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    try {
      final progressJson = json.encode(progress.toJson());
      await sharedPreferences.setString('$_progressKey${progress.bookId}', progressJson);
    } catch (e) {
      throw CacheException('Erro ao salvar progresso de leitura: $e');
    }
  }

  @override
  Future<void> deleteReadingProgress(int bookId) async {
    try {
      await sharedPreferences.remove('$_progressKey$bookId');
    } catch (e) {
      throw CacheException('Erro ao deletar progresso de leitura: $e');
    }
  }
}

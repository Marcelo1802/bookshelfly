import 'package:equatable/equatable.dart';

class GutendexBook extends Equatable {
  final int id;
  final String title;
  final List<GutendexAuthor> authors;
  final List<String> subjects;
  final List<String> bookshelves;
  final List<String> languages;
  final bool copyright;
  final String mediaType;
  final Map<String, String> formats;
  final int downloadCount;

  const GutendexBook({
    required this.id,
    required this.title,
    required this.authors,
    required this.subjects,
    required this.bookshelves,
    required this.languages,
    required this.copyright,
    required this.mediaType,
    required this.formats,
    required this.downloadCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        authors,
        subjects,
        bookshelves,
        languages,
        copyright,
        mediaType,
        formats,
        downloadCount,
      ];

  String? get coverImageUrl => formats['image/jpeg'] ?? formats['image/jpg'];
  String? get epubUrl => formats['application/epub+zip'];
  String? get pdfUrl => formats['application/pdf'];
  String? get textUrl => formats['text/plain'] ?? 
                        formats['text/plain; charset=utf-8'] ?? 
                        formats['text/plain; charset=us-ascii'] ??
                        formats['text/html'] ??
                        formats['text/html; charset=utf-8'];
  
  // Verifica se há algum formato de texto disponível para leitura
  bool get hasReadableText => textUrl != null;
  
  String get authorsNames => authors.map((author) => author.name).join(', ');
  String get subjectsText => subjects.join(', ');
  String get languagesText => languages.join(', ');
}

class GutendexAuthor extends Equatable {
  final String name;
  final int? birthYear;
  final int? deathYear;

  const GutendexAuthor({
    required this.name,
    this.birthYear,
    this.deathYear,
  });

  @override
  List<Object?> get props => [name, birthYear, deathYear];

  String get lifeSpan {
    if (birthYear != null && deathYear != null) {
      return '$birthYear - $deathYear';
    } else if (birthYear != null) {
      return 'Nascido em $birthYear';
    } else if (deathYear != null) {
      return 'Faleceu em $deathYear';
    }
    return 'Ano desconhecido';
  }
}

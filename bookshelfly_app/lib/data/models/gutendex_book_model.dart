import '../../domain/entities/gutendex_book.dart';

class GutendexBookModel extends GutendexBook {
  const GutendexBookModel({
    required super.id,
    required super.title,
    required super.authors,
    required super.subjects,
    required super.bookshelves,
    required super.languages,
    required super.copyright,
    required super.mediaType,
    required super.formats,
    required super.downloadCount,
  });

  factory GutendexBookModel.fromJson(Map<String, dynamic> json) {
    return GutendexBookModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      authors: (json['authors'] as List?)?.map((author) => GutendexAuthorModel.fromJson(author as Map<String, dynamic>)).toList() ?? [],
      subjects: List<String>.from(json['subjects'] ?? []),
      bookshelves: List<String>.from(json['bookshelves'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      copyright: json['copyright'] as bool? ?? false,
      mediaType: json['media_type'] as String? ?? '',
      formats: Map<String, String>.from(json['formats'] ?? {}),
      downloadCount: json['download_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors.map((author) {
        if (author is GutendexAuthorModel) {
          return author.toJson();
        } else {
          return GutendexAuthorModel(name: author.name, birthYear: author.birthYear, deathYear: author.deathYear).toJson();
        }
      }).toList(),
      'subjects': subjects,
      'bookshelves': bookshelves,
      'languages': languages,
      'copyright': copyright,
      'media_type': mediaType,
      'formats': formats,
      'download_count': downloadCount,
    };
  }

  factory GutendexBookModel.fromEntity(GutendexBook book) {
    return GutendexBookModel(
      id: book.id,
      title: book.title,
      authors: book.authors.map((author) {
        if (author is GutendexAuthorModel) {
          return author;
        } else {
          return GutendexAuthorModel(
            name: author.name,
            birthYear: author.birthYear,
            deathYear: author.deathYear,
          );
        }
      }).toList(),
      subjects: book.subjects,
      bookshelves: book.bookshelves,
      languages: book.languages,
      copyright: book.copyright,
      mediaType: book.mediaType,
      formats: book.formats,
      downloadCount: book.downloadCount,
    );
  }
}

class GutendexAuthorModel extends GutendexAuthor {
  const GutendexAuthorModel({
    required super.name,
    super.birthYear,
    super.deathYear,
  });

  factory GutendexAuthorModel.fromJson(Map<String, dynamic> json) {
    return GutendexAuthorModel(
      name: json['name'] as String? ?? 'Autor Desconhecido',
      birthYear: json['birth_year'] as int?,
      deathYear: json['death_year'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birth_year': birthYear,
      'death_year': deathYear,
    };
  }
}

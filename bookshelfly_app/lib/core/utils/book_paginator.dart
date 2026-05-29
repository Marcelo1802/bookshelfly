import 'package:flutter/material.dart';

class BookPage {
  final int pageNumber;
  final String content;
  final int startIndex;
  final int endIndex;

  const BookPage({
    required this.pageNumber,
    required this.content,
    required this.startIndex,
    required this.endIndex,
  });
}

class BookPageChunk {
  final List<BookPage> pages;
  final int nextStartIndex;
  final bool hasMorePages;

  const BookPageChunk({
    required this.pages,
    required this.nextStartIndex,
    required this.hasMorePages,
  });
}

class BookPaginator {
  static List<BookPage> paginateText(
    String text,
    BuildContext context, {
    double fontSize = 18.0,
    double lineHeight = 1.5,
    double horizontalPadding = 32.0,
    double verticalPadding = 32.0,
  }) {
    final List<BookPage> pages = [];
    int currentIndex = 0;
    int pageNumber = 1;

    while (currentIndex < text.length) {
      final chunk = paginateChunk(
        text,
        context,
        startIndex: currentIndex,
        startPageNumber: pageNumber,
        fontSize: fontSize,
        lineHeight: lineHeight,
        horizontalPadding: horizontalPadding,
        verticalPadding: verticalPadding,
      );

      pages.addAll(chunk.pages);
      currentIndex = chunk.nextStartIndex;
      pageNumber += chunk.pages.length;

      if (!chunk.hasMorePages) {
        break;
      }
    }

    return pages;
  }

  static BookPageChunk paginateChunk(
    String text,
    BuildContext context, {
    int startIndex = 0,
    int startPageNumber = 1,
    int maxPages = 20,
    double fontSize = 18.0,
    double lineHeight = 1.5,
    double horizontalPadding = 32.0,
    double verticalPadding = 32.0,
  }) {
    final List<BookPage> pages = [];
    final metrics = _calculatePageMetrics(
      context,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
    );
    final charactersPerPage = metrics.$1;

    int currentIndex = startIndex;
    int pageNumber = startPageNumber;

    while (currentIndex < text.length && pages.length < maxPages) {
      final nextPage = _buildNextPage(
        text,
        currentIndex,
        pageNumber,
        charactersPerPage,
      );

      if (nextPage == null) {
        break;
      }

      pages.add(nextPage);
      pageNumber++;
      currentIndex = nextPage.endIndex;

      while (currentIndex < text.length && text[currentIndex] == ' ') {
        currentIndex++;
      }
    }

    return BookPageChunk(
      pages: pages,
      nextStartIndex: currentIndex,
      hasMorePages: currentIndex < text.length,
    );
  }
  
  // Método auxiliar para encontrar a última pontuação antes de um índice
  static int _findLastPunctuation(String text, int endIndex) {
    final punctuationMarks = ['.', '!', '?', ';', ':'];
    int lastPunctuationIndex = -1;
    
    for (int i = endIndex - 1; i >= 0; i--) {
      if (punctuationMarks.contains(text[i])) {
        lastPunctuationIndex = i;
        break;
      }
    }
    
    return lastPunctuationIndex;
  }
  
  // Método para verificar se uma página termina com ponto final
  static bool endsWithPeriod(String content) {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) return false;
    
    final lastChar = trimmedContent[trimmedContent.length - 1];
    return lastChar == '.';
  }
  
  static int calculateTotalPages(
    String text,
    BuildContext context, {
    double fontSize = 18.0,
    double lineHeight = 1.5,
    double horizontalPadding = 32.0,
    double verticalPadding = 32.0,
  }) {
    // Usar configurações fixas para garantir número consistente de páginas
    final pages = paginateText(
      text,
      context,
      fontSize: fontSize, // Parâmetros mantidos para compatibilidade, mas não usados
      lineHeight: lineHeight,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
    );
    return pages.length;
  }

  static (int, int, int) _calculatePageMetrics(
    BuildContext context, {
    double horizontalPadding = 32.0,
    double verticalPadding = 32.0,
  }) {
    const double baseFontSize = 18.0;
    const double baseLineHeight = 1.5;

    final screenSize = MediaQuery.of(context).size;
    final mediaQuery = MediaQuery.of(context);
    final availableWidth = screenSize.width - horizontalPadding;
    final availableHeight = screenSize.height -
        verticalPadding -
        kToolbarHeight -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;

    final charactersPerLine = (availableWidth / (baseFontSize * 0.6)).round();
    final linesPerPage = (availableHeight / (baseFontSize * baseLineHeight)).round();
    final charactersPerPage = charactersPerLine * linesPerPage;

    return (charactersPerPage, charactersPerLine, linesPerPage);
  }

  static BookPage? _buildNextPage(
    String text,
    int currentIndex,
    int pageNumber,
    int charactersPerPage,
  ) {
    int endIndex = currentIndex + charactersPerPage;

    if (endIndex < text.length) {
      final lastPeriodIndex = text.lastIndexOf('.', endIndex);

      if (lastPeriodIndex > currentIndex) {
        endIndex = lastPeriodIndex + 1;
      } else {
        final lastPunctuationIndex = _findLastPunctuation(text, endIndex);
        if (lastPunctuationIndex > currentIndex) {
          endIndex = lastPunctuationIndex + 1;
        } else {
          final lastSpaceIndex = text.lastIndexOf(' ', endIndex);
          if (lastSpaceIndex > currentIndex) {
            endIndex = lastSpaceIndex;
          }
        }
      }
    } else {
      endIndex = text.length;
    }

    final pageContent = text.substring(currentIndex, endIndex).trim();
    if (pageContent.isEmpty) {
      return null;
    }

    return BookPage(
      pageNumber: pageNumber,
      content: pageContent,
      startIndex: currentIndex,
      endIndex: endIndex,
    );
  }
}

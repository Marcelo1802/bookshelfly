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
    
    // Obter dimensões da tela
    final screenSize = MediaQuery.of(context).size;
    final availableWidth = screenSize.width - horizontalPadding;
    final availableHeight = screenSize.height - verticalPadding - kToolbarHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom;
    
    // Calcular caracteres por linha e linhas por página
    final charactersPerLine = (availableWidth / (fontSize * 0.6)).round(); // Aproximação baseada no tamanho da fonte
    final linesPerPage = (availableHeight / (fontSize * lineHeight)).round();
    final charactersPerPage = charactersPerLine * linesPerPage;
    
    // Dividir o texto em páginas
    int currentIndex = 0;
    int pageNumber = 1;
    
    while (currentIndex < text.length) {
      int endIndex = currentIndex + charactersPerPage;
      
      // Se não é a última página, tentar quebrar após um ponto final
      if (endIndex < text.length) {
        // Procurar pelo último ponto final antes do limite
        int lastPeriodIndex = text.lastIndexOf('.', endIndex);
        
        // Se encontrou um ponto final, usar ele
        if (lastPeriodIndex > currentIndex) {
          endIndex = lastPeriodIndex + 1; // Incluir o ponto final
        } else {
          // Se não encontrou ponto final, procurar por outros sinais de pontuação
          int lastPunctuationIndex = _findLastPunctuation(text, endIndex);
          if (lastPunctuationIndex > currentIndex) {
            endIndex = lastPunctuationIndex + 1;
          } else {
            // Como último recurso, quebrar em uma palavra completa
            int lastSpaceIndex = text.lastIndexOf(' ', endIndex);
            if (lastSpaceIndex > currentIndex) {
              endIndex = lastSpaceIndex;
            }
          }
        }
      } else {
        endIndex = text.length;
      }
      
      final pageContent = text.substring(currentIndex, endIndex).trim();
      
      if (pageContent.isNotEmpty) {
        pages.add(BookPage(
          pageNumber: pageNumber,
          content: pageContent,
          startIndex: currentIndex,
          endIndex: endIndex,
        ));
        pageNumber++;
      }
      
      currentIndex = endIndex;
      
      // Pular espaços em branco
      while (currentIndex < text.length && text[currentIndex] == ' ') {
        currentIndex++;
      }
    }
    
    return pages;
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
    final pages = paginateText(
      text,
      context,
      fontSize: fontSize,
      lineHeight: lineHeight,
      horizontalPadding: horizontalPadding,
      verticalPadding: verticalPadding,
    );
    return pages.length;
  }
}

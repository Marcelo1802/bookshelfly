import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/gutendex_book.dart';
import '../../core/di/injection_container.dart';
import '../../domain/usecases/get_book_content.dart';
import '../../core/utils/book_paginator.dart';
import '../../data/datasources/reading_progress_datasource.dart';
import '../widgets/reading_settings_dialog.dart';

class BookReaderPage extends StatefulWidget {
  final GutendexBook book;

  const BookReaderPage({
    super.key,
    required this.book,
  });

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  final PageController _pageController = PageController();
  String _content = '';
  bool _isLoading = true;
  String? _error;
  
  // Sistema de páginas
  List<BookPage> _pages = [];
  int _currentPage = 0;
  int _totalPages = 0;
  
  // Configurações de leitura
  double _fontSize = 18.0;
  double _lineHeight = 1.5;
  Color _backgroundColor = AppColors.white;
  Color _textColor = AppColors.black;
  bool _isDarkMode = false;
  
  // Progresso de leitura
  late ReadingProgressDataSource _progressDataSource;

  @override
  void initState() {
    super.initState();
    _progressDataSource = ReadingProgressDataSourceImpl(
      sharedPreferences: sl(),
    );
    _loadBookContent();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBookContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.book.textUrl == null) {
        throw Exception('URL do texto não disponível para este livro');
      }

      final getBookContent = sl<GetBookContent>();
      final result = await getBookContent(widget.book.id, widget.book.textUrl!);
      
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _error = failure.message;
          });
        },
        (content) async {
          final cleanedContent = _cleanContent(content);
          await _loadReadingProgress();
          _paginateContent(cleanedContent);
          setState(() {
            _isLoading = false;
            _content = cleanedContent;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String _cleanContent(String content) {
    // Remove tags HTML básicas
    String cleaned = content
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove todas as tags HTML
        .replaceAll('&nbsp;', ' ') // Substitui &nbsp; por espaço
        .replaceAll('&amp;', '&') // Substitui &amp; por &
        .replaceAll('&lt;', '<') // Substitui &lt; por <
        .replaceAll('&gt;', '>') // Substitui &gt; por >
        .replaceAll('&quot;', '"') // Substitui &quot; por "
        .replaceAll('&#39;', "'") // Substitui &#39; por '
        .replaceAll(RegExp(r'\s+'), ' ') // Remove espaços múltiplos
        .trim();

    // Adiciona quebras de linha em pontos apropriados
    cleaned = cleaned
        .replaceAll(RegExp(r'\.\s+'), '.\n\n') // Quebra após pontos
        .replaceAll(RegExp(r'\?\s+'), '?\n\n') // Quebra após interrogações
        .replaceAll(RegExp(r'!\s+'), '!\n\n'); // Quebra após exclamações

    return cleaned;
  }

  void _paginateContent(String content) {
    if (mounted) {
      _pages = BookPaginator.paginateText(
        content,
        context,
        fontSize: _fontSize,
        lineHeight: _lineHeight,
      );
      _totalPages = _pages.length;
      
      // Ir para a página salva ou primeira página
      if (_currentPage >= _totalPages) {
        _currentPage = 0;
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && _currentPage > 0) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _loadReadingProgress() async {
    try {
      final progress = await _progressDataSource.getReadingProgress(widget.book.id);
      if (progress != null) {
        setState(() {
          _currentPage = progress.currentPage;
          _fontSize = progress.fontSize;
          _lineHeight = progress.lineHeight;
          _isDarkMode = progress.isDarkMode;
          _backgroundColor = _isDarkMode ? AppColors.greyDark : AppColors.white;
          _textColor = _isDarkMode ? AppColors.white : AppColors.black;
        });
      }
    } catch (e) {
      // Ignorar erros de progresso, usar configurações padrão
    }
  }

  Future<void> _saveReadingProgress() async {
    try {
      final progress = ReadingProgress(
        bookId: widget.book.id,
        currentPage: _currentPage,
        totalPages: _totalPages,
        lastRead: DateTime.now(),
        fontSize: _fontSize,
        lineHeight: _lineHeight,
        isDarkMode: _isDarkMode,
      );
      await _progressDataSource.saveReadingProgress(progress);
    } catch (e) {
      // Ignorar erros de salvamento
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _saveReadingProgress();
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      // Verificar se a página atual termina com ponto final
      if (_currentPage < _pages.length) {
        final currentPageContent = _pages[_currentPage].content;
        if (!BookPaginator.endsWithPeriod(currentPageContent)) {
          _showNavigationWarning();
          return;
        }
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_totalPages > 0)
              Text(
                'Página ${_currentPage + 1} de $_totalPages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: _isDarkMode 
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.greyDark, AppColors.grey],
                  )
                : AppColors.appBarGradient,
          ),
        ),
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showReadingSettings,
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando livro...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar o livro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookContent,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            physics: _canNavigateToNext() ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Text(
                    page.content,
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: _lineHeight,
                      color: _textColor,
                      fontFamily: 'serif',
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildPageControls(),
      ],
    );
  }

  void _showReadingSettings() {
    showDialog(
      context: context,
      builder: (context) => ReadingSettingsDialog(
        fontSize: _fontSize,
        lineHeight: _lineHeight,
        isDarkMode: _isDarkMode,
        onSettingsChanged: (fontSize, lineHeight, isDarkMode) {
          setState(() {
            _fontSize = fontSize;
            _lineHeight = lineHeight;
            _isDarkMode = isDarkMode;
            _backgroundColor = isDarkMode ? AppColors.greyDark : AppColors.white;
            _textColor = isDarkMode ? AppColors.white : AppColors.black;
          });
          
          // Não repaginar - as páginas permanecem fixas
          // Apenas as configurações de exibição são aplicadas
          
          _saveReadingProgress();
        },
      ),
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _backgroundColor = _isDarkMode ? AppColors.greyDark : AppColors.white;
      _textColor = _isDarkMode ? AppColors.white : AppColors.black;
    });
    _saveReadingProgress();
  }

  void _showNavigationWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Termine de ler a página atual antes de prosseguir',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showQuickNavigationDialog() {
    final TextEditingController pageController = TextEditingController(
      text: (_currentPage + 1).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navegação Rápida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Digite o número da página (1 - $_totalPages)',
              style: TextStyle(
                color: _textColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Ex: 90',
                hintStyle: TextStyle(
                  color: _textColor.withOpacity(0.6),
                ),
              ),
              onSubmitted: (value) {
                _navigateToPage(value, pageController);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _navigateToPage('1', pageController),
                  child: const Text('Primeira'),
                ),
                TextButton(
                  onPressed: () => _navigateToPage(_totalPages.toString(), pageController),
                  child: const Text('Última'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _navigateToPage(pageController.text, pageController),
            child: const Text('Ir'),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(String pageText, TextEditingController controller) {
    final pageNumber = int.tryParse(pageText);
    
    if (pageNumber == null || pageNumber < 1 || pageNumber > _totalPages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Digite um número válido entre 1 e $_totalPages',
            style: const TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    final targetPage = pageNumber - 1; // Converter para índice baseado em 0
    
    // Verificar se a página atual termina com ponto final (se não for a primeira página)
    if (targetPage > _currentPage && _currentPage < _pages.length) {
      final currentPageContent = _pages[_currentPage].content;
      if (!BookPaginator.endsWithPeriod(currentPageContent)) {
        _showNavigationWarning();
        return;
      }
    }

    Navigator.of(context).pop();
    
    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _canNavigateToNext() {
    if (_currentPage >= _pages.length) return false;
    final currentPageContent = _pages[_currentPage].content;
    return BookPaginator.endsWithPeriod(currentPageContent);
  }

  Widget _buildPageControls() {
    if (_totalPages <= 1) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _isDarkMode ? AppColors.greyDark : AppColors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _isDarkMode ? AppColors.grey : AppColors.greyLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botão Página Anterior
          _buildMenuButton(
            icon: Icons.chevron_left,
            onPressed: _currentPage > 0 ? _goToPreviousPage : null,
            isEnabled: _currentPage > 0,
          ),
          
          // Indicador de Página (Navegação Rápida)
          GestureDetector(
            onTap: _showQuickNavigationDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isDarkMode ? AppColors.grey : AppColors.greyLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _textColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_currentPage + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  Text(
                    ' / $_totalPages',
                    style: TextStyle(
                      fontSize: 14,
                      color: _textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.navigation,
                    size: 16,
                    color: _textColor.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),
          
          // Botão Página Seguinte
          _buildMenuButton(
            icon: Icons.chevron_right,
            onPressed: (_currentPage < _totalPages - 1 && _canNavigateToNext()) ? _goToNextPage : null,
            isEnabled: (_currentPage < _totalPages - 1 && _canNavigateToNext()),
          ),
        ],
      ),
    );
  }


  Widget _buildMenuButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEnabled 
            ? (_isDarkMode ? AppColors.grey : AppColors.greyLight)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isEnabled ? _textColor : AppColors.grey,
          size: 24,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../data/datasources/user_books_datasource.dart';
import '../../domain/entities/gutendex_book.dart';
import '../widgets/loading_widget.dart';
import 'book_reader_page.dart';

class GlassPage extends StatefulWidget {
  const GlassPage({super.key});

  @override
  State<GlassPage> createState() => _GlassPageState();
}

class _GlassPageState extends State<GlassPage> {
  late UserBooksDataSource _userBooksDataSource;
  List<GutendexBook> _favoriteBooks = [];
  List<GutendexBook> _readingBooks = [];
  bool _isLoading = true;
  bool _showReading = true; // true = Lendo, false = Favoritos

  @override
  void initState() {
    super.initState();
    _userBooksDataSource = sl<UserBooksDataSource>();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _userBooksDataSource.getFavoriteBooks();
      final reading = await _userBooksDataSource.getReadingBooks();
      
      if (mounted) {
        setState(() {
          _favoriteBooks = favorites;
          _readingBooks = reading;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Em caso de erro, limpar as listas e mostrar estado vazio
      if (mounted) {
        setState(() {
          _favoriteBooks = [];
          _readingBooks = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: LoadingWidget())
            : RefreshIndicator(
                onRefresh: _loadBooks,
                child: Column(
                  children: [
                    // Barra de busca
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'buscar livros',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Tabs Lendo e Favoritos
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              'lendo',
                              _showReading,
                              AppColors.primary,
                              () => setState(() => _showReading = true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTabButton(
                              'favoritos',
                              !_showReading,
                              Colors.red,
                              () => setState(() => _showReading = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Grid de livros
                    Expanded(
                      child: _buildBooksGrid(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, Color selectedColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : AppColors.greyLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBooksGrid() {
    final books = _showReading ? _readingBooks : _favoriteBooks;
    
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/glass.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Nenhum livro ${_showReading ? "em leitura" : "favoritado"}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _showReading 
                    ? 'Comece a ler livros para vê-los aqui'
                    : 'Favorite livros para vê-los aqui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return _buildBookGridItem(books[index]);
      },
    );
  }

  Widget _buildBookGridItem(GutendexBook book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookReaderPage(book: book),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildBookCover(book),
                  ),
                ),
              ),
              // Botão X vermelho - posicionado como o círculo na imagem
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () => _removeBook(book),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.title,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          book.authorsNames.isNotEmpty 
              ? book.authorsNames.split(',').first.trim()
              : 'Autor Desconhecido',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _removeBook(GutendexBook book) async {
    // Mostrar diálogo de confirmação
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Confirmar remoção',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        content: Text(
          'Deseja remover "${book.title}" ${_showReading ? "da lista de leitura" : "dos favoritos"}?',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Remover',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    // Se o usuário confirmou, remover o livro
    if (confirmed != true) return;

    try {
      if (_showReading) {
        await _userBooksDataSource.removeReadingBook(book.id);
        setState(() {
          _readingBooks.removeWhere((b) => b.id == book.id);
        });
      } else {
        await _userBooksDataSource.removeFavoriteBook(book.id);
        setState(() {
          _favoriteBooks.removeWhere((b) => b.id == book.id);
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${book.title} foi removido ${_showReading ? "da leitura" : "dos favoritos"}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao remover livro'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }


  Widget _buildBookCover(GutendexBook book) {
    final coverUrl = book.coverImageUrl;
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return Image.network(
        coverUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderCover();
        },
      );
    }
    return _buildPlaceholderCover();
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.book,
        color: AppColors.white,
        size: 40,
      ),
    );
  }
}


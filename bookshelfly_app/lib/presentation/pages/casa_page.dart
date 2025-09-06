import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/gutendex_book.dart';
import '../viewmodels/books_viewmodel.dart';
import '../widgets/loading_widget.dart';
import 'book_reader_page.dart';

class CasaPage extends StatefulWidget {
  const CasaPage({super.key});

  @override
  State<CasaPage> createState() => _CasaPageState();
}

class _CasaPageState extends State<CasaPage> {
  Timer? _timer;
  int _currentFeaturedIndex = 0;
  List<GutendexBook> _featuredBooks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<BooksViewModel>();
      if (viewModel.books.isEmpty) {
        viewModel.loadBooks(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoSlide(List<GutendexBook> books) {
    _timer?.cancel();
    if (books.length > 1) {
      _featuredBooks = books.take(5).toList();
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          setState(() {
            _currentFeaturedIndex = (_currentFeaturedIndex + 1) % _featuredBooks.length;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<BooksViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.books.isEmpty) {
              return const Center(child: LoadingWidget());
            }

            final books = viewModel.books;
            if (books.isEmpty) {
              return _buildEmptyState();
            }

            // Iniciar auto slide apenas uma vez
            if (_featuredBooks.isEmpty && books.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startAutoSlide(books);
              });
            }

            return CustomScrollView(
              slivers: [
                _buildFeaturedCard(books),
                _buildDivider(),
                _buildSectionTitle('Popular'),
                _buildHorizontalBookList(books.take(10).toList()),
                _buildDivider(),
                _buildSectionTitle('Clássicos'),
                _buildHorizontalBookList(books.skip(10).take(10).toList()),
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(List<GutendexBook> books) {
    if (_featuredBooks.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    final currentBook = _featuredBooks[_currentFeaturedIndex];
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do livro (lado esquerdo)
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentBook.authorsNames.isNotEmpty 
                        ? currentBook.authorsNames.split(',').first.trim()
                        : 'Autor Desconhecido',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentBook.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: currentBook.hasReadableText
                            ? () => _openBookReader(currentBook)
                            : null,
                        icon: const Icon(Icons.menu_book, size: 18),
                        label: const Text('Ler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentBook.hasReadableText 
                              ? AppColors.white 
                              : AppColors.grey,
                          foregroundColor: currentBook.hasReadableText 
                              ? AppColors.black 
                              : AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24, 
                            vertical: 12
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'EN',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Foto do livro (lado direito)
            Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: currentBook.coverImageUrl != null
                    ? Image.network(
                        currentBook.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryLight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.book,
                                  color: AppColors.white,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, 
                                    vertical: 4
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Foto\nLivro',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.primaryLight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.book,
                              color: AppColors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 4
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Foto\nLivro',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        height: 2,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalBookList(List<GutendexBook> books) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () => _openBookReader(book),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: book.coverImageUrl != null
                              ? Image.network(
                                  book.coverImageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      color: AppColors.primaryLight,
                                      child: const Icon(
                                        Icons.book,
                                        color: AppColors.white,
                                        size: 40,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: double.infinity,
                                  color: AppColors.primaryLight,
                                  child: const Icon(
                                    Icons.book,
                                    color: AppColors.white,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.title,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 13,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: AppColors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Carregando biblioteca...',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _openBookReader(GutendexBook book) {
    if (book.hasReadableText) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookReaderPage(book: book),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texto deste livro não está disponível para leitura online.'),
          backgroundColor: AppColors.grey,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
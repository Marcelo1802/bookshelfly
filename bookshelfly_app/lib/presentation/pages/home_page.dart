import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/gutendex_book.dart';
import '../../core/utils/web_url_proxy.dart';
import '../viewmodels/books_viewmodel.dart';
import '../widgets/loading_widget.dart';
import 'book_reader_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static const int _sectionBookCount = 6;
  Timer? _timer;
  int _currentFeaturedIndex = 0;
  List<GutendexBook> _featuredBooks = [];
  late AnimationController _borderAnimationController;

  @override
  void initState() {
    super.initState();
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    // Carregar cache imediatamente para exibição instantânea (sem esperar postFrameCallback)
    Future.microtask(() {
      if (mounted) {
        final viewModel = context.read<BooksViewModel>();
        // Carregar cache do banner imediatamente (mesmo que expirado)
        viewModel.loadCachedFeaturedBooksImmediate();
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<BooksViewModel>();
      // Depois carregar dados atualizados em background
      if (viewModel.featuredBooks.isEmpty) {
        viewModel.loadFeaturedBooks();
      }
      // Carregar livros brasileiros
      if (viewModel.brazilianBooks.isEmpty) {
        viewModel.loadBrazilianBooks();
      }
      // Carregar seções Popular e Clássicos em background
      if (viewModel.books.isEmpty) {
        viewModel.loadBooks(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _borderAnimationController.dispose();
    super.dispose();
  }

  void _startAutoSlide(List<GutendexBook> books) {
    _timer?.cancel();
    if (books.isNotEmpty && mounted) {
      setState(() {
        _featuredBooks = books;
        _currentFeaturedIndex = 0;
      });
    }

    if (books.length > 1) {
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
            final featuredBooks = viewModel.featuredBooks;
            final brazilianBooks = viewModel.brazilianBooks;
            final popularBooks = viewModel.books;
            final hasHomeContent =
                featuredBooks.isNotEmpty || brazilianBooks.isNotEmpty;

            if (!hasHomeContent &&
                (viewModel.isLoadingFeatured || viewModel.isLoadingBrazilian)) {
              return const Center(child: LoadingWidget());
            }

            if (!hasHomeContent) {
              return _buildEmptyState();
            }

            // Iniciar auto slide apenas uma vez
            if (_featuredBooks.isEmpty && featuredBooks.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startAutoSlide(featuredBooks);
              });
            }

            return CustomScrollView(
              slivers: [
                featuredBooks.isNotEmpty
                    ? _buildFeaturedCard(featuredBooks)
                    : _buildFeaturedLoadingCard(),
                _buildDivider(),
                if (viewModel.brazilianBooks.isNotEmpty) ...[
                  _buildSectionTitle('🇧🇷 Brasileiros'),
                  _buildHorizontalBookList(viewModel.brazilianBooks),
                  _buildDivider(),
                ] else if (viewModel.isLoadingBrazilian) ...[
                  _buildSectionTitle('🇧🇷 Brasileiros'),
                  _buildHorizontalLoadingList(),
                  _buildDivider(),
                ],
                if (popularBooks.isNotEmpty) ...[
                  _buildSectionTitle('Popular'),
                  _buildHorizontalBookList(popularBooks.take(_sectionBookCount).toList()),
                  _buildDivider(),
                  if (popularBooks.length > _sectionBookCount) ...[
                    _buildSectionTitle('Clássicos'),
                    _buildHorizontalBookList(
                      popularBooks
                          .skip(_sectionBookCount)
                          .take(_sectionBookCount)
                          .toList(),
                    ),
                  ] else if (viewModel.isLoading) ...[
                    _buildSectionTitle('Clássicos'),
                    _buildHorizontalLoadingList(),
                  ],
                ] else if (viewModel.isLoading) ...[
                  _buildSectionTitle('Popular'),
                  _buildHorizontalLoadingList(),
                  _buildDivider(),
                  _buildSectionTitle('Clássicos'),
                  _buildHorizontalLoadingList(),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(List<GutendexBook> books) {
    final sourceBooks = _featuredBooks.isNotEmpty ? _featuredBooks : books;
    if (sourceBooks.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final currentBook = sourceBooks[_currentFeaturedIndex % sourceBooks.length];
    
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
                      AnimatedBuilder(
                        animation: _borderAnimationController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              color: currentBook.hasReadableText 
                                  ? Colors.red 
                                  : AppColors.grey,
                              borderRadius: BorderRadius.circular(12),
                              border: currentBook.hasReadableText
                                  ? Border.all(
                                      color: _getAnimatedBorderColor(),
                                      width: 2.5,
                                    )
                                  : null,
                              boxShadow: currentBook.hasReadableText ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: ElevatedButton(
                              onPressed: currentBook.hasReadableText
                                  ? () => _openBookReader(currentBook)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: AppColors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32, 
                                  vertical: 14
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Ler',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          );
                        },
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
                        proxiedWebUrl(currentBook.coverImageUrl!),
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

  Widget _buildFeaturedLoadingCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.75),
              AppColors.primaryDark.withValues(alpha: 0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLoadingBar(width: 110, height: 18, color: AppColors.white.withValues(alpha: 0.35)),
                  const SizedBox(height: 12),
                  _buildLoadingBar(width: 240, height: 34, color: AppColors.white.withValues(alpha: 0.45)),
                  const SizedBox(height: 10),
                  _buildLoadingBar(width: 190, height: 20, color: AppColors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 20),
                  _buildLoadingBar(width: 96, height: 42, color: Colors.red.withValues(alpha: 0.7)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
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
                                  proxiedWebUrl(book.coverImageUrl!),
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

  Widget _buildHorizontalLoadingList() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLoadingBar(width: 110, height: 14),
                  const SizedBox(height: 6),
                  _buildLoadingBar(width: 80, height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingBar({
    required double width,
    required double height,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.greyLight,
        borderRadius: BorderRadius.circular(height / 2),
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

  Color _getAnimatedBorderColor() {
    // Cria um efeito de borda "andando" usando seno/cosseno
    final value = _borderAnimationController.value;
    final opacity = (0.3 + (0.7 * (0.5 + 0.5 * sin(value * 2 * pi)))).clamp(0.3, 1.0);
    return AppColors.white.withOpacity(opacity);
  }
}

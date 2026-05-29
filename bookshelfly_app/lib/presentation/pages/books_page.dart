import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/books_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/injection_container.dart';
import '../../data/datasources/user_books_datasource.dart';
import '../../data/models/gutendex_book_model.dart';
import '../../domain/entities/gutendex_book.dart';
import '../../core/utils/web_url_proxy.dart';
import '../widgets/book_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as custom;
import '../widgets/search_bar_widget.dart';
import 'book_reader_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  static const int _booksPageSize = 7;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<BooksViewModel>();
      if (viewModel.books.isEmpty) {
        viewModel.loadBooks(refresh: true, pageSize: _booksPageSize);
      }
    });
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BooksViewModel>().loadMoreBooks(pageSize: _booksPageSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        foregroundColor: AppColors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          const SearchBarWidget(pageSize: _booksPageSize),
          Expanded(
            child: Consumer<BooksViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.books.isEmpty) {
                  return const LoadingWidget();
                }

                if (viewModel.error != null && viewModel.books.isEmpty) {
                  return custom.ErrorWidget(
                    message: viewModel.error!,
                    onRetry: () => viewModel.loadBooks(
                      refresh: true,
                      pageSize: _booksPageSize,
                    ),
                  );
                }

                if (viewModel.books.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildBooksList(viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum livro encontrado',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar por um termo diferente',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(BooksViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.loadBooks(
        refresh: true,
        pageSize: _booksPageSize,
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.books.length + (viewModel.hasMoreBooks ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= viewModel.books.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final book = viewModel.books[index];
          return BookCard(
            book: book,
            onTap: () => _showBookDetails(context, book),
          );
        },
      ),
    );
  }

  void _showBookDetails(BuildContext context, GutendexBook book) {
    if (kIsWeb) {
      showGeneralDialog<void>(
        context: context,
        barrierLabel: 'Fechar detalhes do livro',
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: BookDetailsSheet(
                      book: book,
                      centered: true,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookDetailsSheet(book: book),
    );
  }
}

class BookDetailsSheet extends StatefulWidget {
  final GutendexBook book;
  final bool centered;

  const BookDetailsSheet({
    super.key,
    required this.book,
    this.centered = false,
  });

  @override
  State<BookDetailsSheet> createState() => _BookDetailsSheetState();
}

class _BookDetailsSheetState extends State<BookDetailsSheet> {
  bool _isFavorited = false;
  bool _isReading = false;
  late UserBooksDataSource _userBooksDataSource;

  @override
  void initState() {
    super.initState();
    _userBooksDataSource = sl<UserBooksDataSource>();
    _loadBookStates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarregar estado quando a página voltar ao foco
    // Isso garante que se o livro foi removido na Glass, o estado seja atualizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookStates();
    });
  }

  Future<void> _loadBookStates() async {
    final isFavorite = await _userBooksDataSource.isFavoriteBook(widget.book.id);
    final isReading = await _userBooksDataSource.isReadingBook(widget.book.id);
    
    if (mounted) {
      setState(() {
        _isFavorited = isFavorite;
        _isReading = isReading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : screenSize.width;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : screenSize.height;
        final isCompact = availableWidth < 640;
        final dialogWidth = widget.centered
            ? availableWidth.clamp(320.0, 860.0)
            : availableWidth;
        final dialogHeight = widget.centered
            ? availableHeight.clamp(420.0, screenSize.height * 0.88)
            : screenSize.height * 0.8;

        return Align(
          alignment: widget.centered ? Alignment.center : Alignment.bottomCenter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: dialogWidth,
                height: dialogHeight,
                margin: widget.centered
                    ? const EdgeInsets.all(0)
                    : EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: widget.centered
                      ? BorderRadius.circular(24)
                      : const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          isCompact ? 16 : 24,
                          isCompact ? 12 : 20,
                          isCompact ? 16 : 24,
                          isCompact ? 16 : 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isCompact)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCover(),
                                  const SizedBox(height: 16),
                                  _buildHeaderText(),
                                ],
                              )
                            else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCover(),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildHeaderText()),
                                ],
                              ),
                            const SizedBox(height: 24),
                            if (widget.book.subjects.isNotEmpty) ...[
                              Container(
                                height: 2,
                                color: AppColors.grey,
                                margin: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              const Text(
                                'Assuntos:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.book.subjectsText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.greyDark,
                                ),
                              ),
                              Container(
                                height: 2,
                                color: AppColors.grey,
                                margin: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ],
                            if (widget.book.languages.isNotEmpty) ...[
                              const Text(
                                'Idiomas:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.book.languagesText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.greyDark,
                                ),
                              ),
                              Container(
                                height: 2,
                                color: AppColors.grey,
                                margin: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ],
                            if (isCompact)
                              Column(
                                children: [
                                  _buildReadButton(),
                                  const SizedBox(height: 12),
                                  _buildFavoriteButton(),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(child: _buildReadButton()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildFavoriteButton()),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCover() {
    if (widget.book.coverImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          proxiedWebUrl(widget.book.coverImageUrl!),
          width: 120,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.book,
                color: AppColors.white,
                size: 50,
              ),
            );
          },
        ),
      );
    }

    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.book,
        color: AppColors.white,
        size: 50,
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.book.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.book.authorsNames,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.greyDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.download,
              size: 16,
              color: AppColors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.book.downloadCount} downloads',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: _isReading ? AppColors.primaryGradient : null,
        color: _isReading ? null : AppColors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: widget.book.hasReadableText ? AppColors.primary : AppColors.grey,
          width: 2,
        ),
        boxShadow: _isReading
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: widget.book.hasReadableText
            ? () => _toggleReading(context, widget.book)
            : () => _showNoTextAvailable(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _isReading
              ? AppColors.white
              : (widget.book.hasReadableText ? AppColors.primary : AppColors.grey),
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          _isReading ? 'Lendo' : 'Ler Livro',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _isFavorited ? Colors.red : AppColors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.red,
          width: 2,
        ),
        boxShadow: _isFavorited
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: () => _toggleFavorite(context, widget.book),
        icon: Icon(
          _isFavorited ? Icons.favorite : Icons.favorite_border,
          size: 20,
        ),
        label: Text(
          _isFavorited ? 'Favoritado' : 'Favoritar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _isFavorited ? AppColors.white : Colors.red,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }


  void _openBookReader(BuildContext context, GutendexBook book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookReaderPage(book: book),
      ),
    );
  }

  void _showNoTextAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto deste livro não está disponível para leitura online.'),
        backgroundColor: AppColors.grey,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _toggleFavorite(BuildContext context, GutendexBook book) async {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    
    // Salvar no storage
    final bookModel = GutendexBookModel.fromEntity(book);
    if (_isFavorited) {
      await _userBooksDataSource.addFavoriteBook(bookModel);
    } else {
      await _userBooksDataSource.removeFavoriteBook(book.id);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorited 
            ? '${book.title} foi adicionado aos favoritos!' 
            : '${book.title} foi removido dos favoritos!'),
        backgroundColor: _isFavorited ? Colors.red : AppColors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleReading(BuildContext context, GutendexBook book) async {
    // Se já está lendo, apenas abre o leitor sem mudar o estado
    if (_isReading) {
      _openBookReader(context, book);
      return;
    }
    
    // Se não está lendo, muda para "Lendo" e abre o leitor
    setState(() {
      _isReading = true;
    });
    
    // Salvar no storage
    final bookModel = GutendexBookModel.fromEntity(book);
    await _userBooksDataSource.addReadingBook(bookModel);
    
    // Abrir o leitor
    _openBookReader(context, book);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Começando a ler ${book.title}!'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

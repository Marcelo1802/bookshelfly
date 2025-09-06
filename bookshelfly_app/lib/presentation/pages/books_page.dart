import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/books_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/gutendex_book.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksViewModel>().loadBooks(refresh: true);
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
      context.read<BooksViewModel>().loadMoreBooks();
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
          const SearchBarWidget(),
          Expanded(
            child: Consumer<BooksViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading && viewModel.books.isEmpty) {
                  return const LoadingWidget();
                }

                if (viewModel.error != null && viewModel.books.isEmpty) {
                  return custom.ErrorWidget(
                    message: viewModel.error!,
                    onRetry: () => viewModel.loadBooks(refresh: true),
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
      onRefresh: () => viewModel.loadBooks(refresh: true),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookDetailsSheet(book: book),
    );
  }
}

class BookDetailsSheet extends StatelessWidget {
  final GutendexBook book;

  const BookDetailsSheet({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (book.coverImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            book.coverImageUrl!,
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
                        )
                      else
                        Container(
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
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.authorsNames,
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
                                  '${book.downloadCount} downloads',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (book.subjects.isNotEmpty) ...[
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
                      book.subjectsText,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (book.languages.isNotEmpty) ...[
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
                      book.languagesText,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Botão de leitura
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: book.hasReadableText 
                          ? () => _openBookReader(context, book)
                          : () => _showNoTextAvailable(context),
                      icon: const Icon(Icons.menu_book),
                      label: Text(book.hasReadableText ? 'Ler Livro' : 'Texto Não Disponível'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: book.hasReadableText 
                            ? AppColors.primary 
                            : AppColors.grey,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Formatos Disponíveis:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (book.epubUrl != null)
                        _buildFormatChip('EPUB', book.epubUrl!),
                      if (book.pdfUrl != null)
                        _buildFormatChip('PDF', book.pdfUrl!),
                      if (book.textUrl != null)
                        _buildFormatChip('TXT', book.textUrl!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String label, String url) {
    return InkWell(
      onTap: () {
        // TODO: Implementar download ou abertura do arquivo
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
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
}

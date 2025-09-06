import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'casa_page.dart';
import 'books_page.dart';
import 'esportes_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const CasaPage(), // Home estilo Netflix para livros
    const BooksPage(), // Buscar livros
    const EsportesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

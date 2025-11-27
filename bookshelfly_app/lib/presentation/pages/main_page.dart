import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'home_page.dart';
import 'books_page.dart';
import 'notes_page.dart';
import 'glass_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(), // Home estilo Netflix para livros
    const BooksPage(), // Buscar livros
    const NotesPage(), // Anotações
    const GlassPage(), // Glass
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

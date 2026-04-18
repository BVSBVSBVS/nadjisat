import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'post_oglas_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const PostOglasScreen(),
    const Center(child: Text("Oglasi koje pratim")),
    const Center(child: Text("Moji oglasi / Profil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Pretraga'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Postavi oglas'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Pratim'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Moji oglasi'),
        ],
      ),
    );
  }
}
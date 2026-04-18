import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _trenutniIndex = 0;

  // Ovde ćemo kasnije ubacivati prave ekrane koje budemo pravili
  final List<Widget> _ekrani = [
    const Center(child: Text("Ovdje ide: SVI OGLASI (50 NAJNOVIJIH)")),
    const Center(child: Text("Ovdje ide: MOJI OGLASI I DODAVANJE")),
    const Center(child: Text("Ovdje ide: PROFIL KORISNIKA")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NadjiSat", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _ekrani[_trenutniIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _trenutniIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _trenutniIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
          BottomNavigationBarItem(icon: Icon(Icons.watch), label: 'Moji Oglasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
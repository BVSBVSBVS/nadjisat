import 'oglasi_screen.dart';
import 'oglasi_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Uvozimo onaj tvoj prelepi dizajn od juče

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // Počinjemo od nule (0 = Oglasi)

  // Ovde držimo svih 5 ekrana
  final List<Widget> _pages = [
    // 0. Oglasi (Početna)
    const Center(child: Text("Svi Oglasi (Skupi, jeftini, plaćeni, sve na gomili)", style: TextStyle(fontSize: 20))),
    // 1. Praćeni
    const Center(child: Text("Praćeni Oglasi (Označeni srcem)", style: TextStyle(fontSize: 20))),
    // 2. Pretraga
    const Center(child: Text("Pretraga (Ovde idu hiljade filtera)", style: TextStyle(fontSize: 20))),
    // 3. Moji oglasi
    const Center(child: Text("Moji oglasi (Mrtvo ako korisnik nije ulogovan)", style: TextStyle(fontSize: 20))),
    // 4. Profil (Tvoj Login/Registracija ekran)
    const LoginScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Body prikazuje onaj ekran na koji si kliknuo dole
      body: _pages[_selectedIndex],
      
      // Taskbar na dnu
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Obavezno 'fixed' kad imaš više od 3 taba
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black, // Crna za taj "High-End" Polovni Automobili vajb
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Menja ekran kad klikneš
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Oglasi'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Praćeni'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Pretraži'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Moji oglasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
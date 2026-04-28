import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Uvezi tvoje ekrane
import 'home_screen.dart';
import 'post_oglas_screen.dart';
import 'praceni_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _trenutniIndex = 0;

  // Lista ekrana 
  final List<Widget> _ekrani = [
    const HomeScreen(),
    const PostOglasScreen(),
    const PraceniScreen(),
    const ProfileScreen(),
  ];

  void _naTapkanje(int index) {
    setState(() {
      _trenutniIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Proveravamo da li je upaljen Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Naša luksuzna Marine plava
    const Color marineBlue = Color(0xFF0A2647);
    
    // Određujemo aktivnu boju zavisno od teme (Bela sija u mraku, Marine plava ubija na svetlu)
    final Color aktivnaBoja = isDark ? Colors.white : marineBlue;
    final Color neaktivnaBoja = isDark ? Colors.grey[500]! : Colors.grey[600]!;

    return Scaffold(
      body: _ekrani[_trenutniIndex],
      
      // Dodajemo malu senku iznad menija za 3D premium efekat
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          type: BottomNavigationBarType.fixed, 
          currentIndex: _trenutniIndex,
          onTap: _naTapkanje,
          
          // Podešavanja boja
          selectedItemColor: aktivnaBoja,
          unselectedItemColor: neaktivnaBoja,
          
          // PODEBLJAVAMO FONTOVE DA SE JASNO VIDE
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          
          elevation: 0, // Senku smo rešili iznad kontejnerom
          
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.search, size: 24),
              // Kad je aktivno, ikonica je malo veća i deblja
              activeIcon: Icon(CupertinoIcons.search, size: 28, color: aktivnaBoja),
              label: 'Pretraga',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.add_circled, size: 24),
              // Koristimo "solid" popunjenu ikonicu kad se klikne
              activeIcon: Icon(CupertinoIcons.add_circled_solid, size: 28, color: aktivnaBoja),
              label: 'Postavi',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.heart, size: 24),
              // Crveno srce koje kuca kad je aktivno
              activeIcon: const Icon(CupertinoIcons.heart_solid, size: 28, color: Colors.redAccent), 
              label: 'Pratim',
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person, size: 24),
              // Popunjen čovečuljak kad je u profilu
              activeIcon: Icon(CupertinoIcons.person_solid, size: 28, color: aktivnaBoja),
              label: 'Moj Profil',
            ),
          ],
        ),
      ),
    );
  }
}
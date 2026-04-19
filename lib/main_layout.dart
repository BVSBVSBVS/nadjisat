import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Uvezi tvoje ekrane (proveri da li se fajlovi ovako zovu kod tebe)
import 'home_screen.dart';
import 'post_oglas_screen.dart';
import 'profile_screen.dart'; // Ako imaš poseban ekran za profil
// import 'pratim_screen.dart'; // Ako imaš ekran za praćene oglase (ako ne, stavićemo prazan kontejner za sad)

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _trenutniIndex = 0;

  // Lista ekrana (MORA DA IH IMA 4 DA BI SE GAĐALO SA IKONICAMA)
  final List<Widget> _ekrani = [
    const HomeScreen(),
    const PostOglasScreen(),
    Container(color: Colors.white, child: const Center(child: Text("Pratim - Uskoro"))), // Zameni sa tvojim ekranom ako ga imaš
    const ProfileScreen(), // Ili kako god ti se zove ekran za profil/oglase
  ];

  void _naTapkanje(int index) {
    setState(() {
      _trenutniIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ekrani[_trenutniIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Važno da se vide sve 4 ikonice
        currentIndex: _trenutniIndex,
        onTap: _naTapkanje,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Pretraga',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled),
            label: 'Postavi oglas',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart),
            label: 'Pratim',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Moj Profil',
          ),
        ],
      ),
    );
  }
}
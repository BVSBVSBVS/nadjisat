import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_layout.dart'; // Proveri da li ti se početni fajl ovako zove (ili login_screen.dart)

// 1. OVO JE GLOBALNI PREKIDAČ ZA CELU APLIKACIJU
final ValueNotifier<bool> isDarkModeGlobal = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // OSTAVI TVOJE KLJUČEVE OVDE!
  await Supabase.initialize(
    url: 'https://gvayuhokaipgeipfsiok.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2YXl1aG9rYWlwZ2VpcGZzaW9rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NjI2MTcsImV4cCI6MjA5MjAzODYxN30.gbOXUpldHzwUGy1GMNTA_B5e_oPUIi1yCoIv9H6v53A',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. ValueListenableBuilder "sluša" da li je neko kliknuo prekidač bilo gde u aplikaciji
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NadjiSat',
          
          // 3. ODLUČUJE KOJA TEMA SE KORISTI
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          
          // --- SVETLA TEMA (Kao do sada) ---
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF2F2F7),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF89CFF0), // Bebi plava
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
          ),
          
          // --- TAMNA TEMA (Dark Mode) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF000000), // Skroz crna
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1C1C1E), // Tamno siva Apple
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1C1C1E),
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
            ),
            cardColor: const Color(0xFF1C1C1E), // Boja kartica u tamnoj temi
          ),
          
          home: const MainLayout(), // Zameni sa svojim početnim ekranom ako se zove drugačije
        );
      }
    );
  }
}
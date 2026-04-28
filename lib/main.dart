import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- DODALI SMO OVO

import 'main_layout.dart'; 

final ValueNotifier<bool> isDarkModeGlobal = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Učitavamo tajni sef pre nego što se aplikacija upali
  await dotenv.load(fileName: ".env");
  
  // SADA SU KLJUČEVI SAKRIVENI!
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!, 
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

// ... ostatak tvog koda ostaje isti (class MyApp extends StatelessWidget...)
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
          
          // --- SVETLA TEMA (Premium Marine Plava) ---
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF0A2647), // Premium Marine
            scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Skupa, jako svetlo siva
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0A2647), // Tamno plavi gornji meni
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF0A2647), // Zamenjena ona obična plava
              unselectedItemColor: Colors.grey,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0A2647),
              primary: const Color(0xFF0A2647),
            ),
          ),
          
          // --- TAMNA TEMA (Apple stil) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF0A2647),
            scaffoldBackgroundColor: const Color(0xFF000000), // Skroz crna
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1C1C1E), // Tamno siva Apple
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1C1C1E),
              selectedItemColor: Colors.white, // Bela za selekciju da bi "vrištala" iz mraka
              unselectedItemColor: Colors.grey,
            ),
            cardColor: const Color(0xFF1C1C1E), // Boja kartica u tamnoj temi
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF0A2647),
              primary: Colors.blue[300]!, // Svetliji akcenat za tamni mod da se tekstovi dobro vide
            ),
          ),
          
          home: const MainLayout(), // Zameni sa svojim početnim ekranom ako se zove drugačije
        );
      }
    );
  }
}
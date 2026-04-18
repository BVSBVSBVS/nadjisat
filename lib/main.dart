import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tvoji Supabase ključevi su bezbedno povezani
  await Supabase.initialize(
    url: 'https://gvayuhokaipgeipfsiok.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2YXl1aG9rYWlwZ2VpcGZzaW9rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NjI2MTcsImV4cCI6MjA5MjAzODYxN30.gbOXUpldHzwUGy1GMNTA_B5e_oPUIi1yCoIv9H6v53A',
  );

  runApp(const NadjiSatApp());
}

class NadjiSatApp extends StatelessWidget {
  const NadjiSatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NadjiSat',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Premium siva pozadina
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.orange[700], // Zlatno-narandžasta za aktivan tab!
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
        ),
      ),
      // AuthChecker automatski prebacuje ekrane zavisno od toga da li si ulogovan
      home: const AuthChecker(), 
    );
  }
}

// Ovaj widget non-stop dežura i gleda da li si ulogovan ili izlogovan
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    
    // Ako imaš nalog i ulogovan si -> ideš na Glavni ekran
    if (session != null) {
      return const MainLayout();
    } 
    // Ako nemaš nalog -> ideš na Login (gde ćemo napraviti Guest mode)
    else {
      return const LoginScreen();
    }
  }
}
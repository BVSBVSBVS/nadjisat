import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_layout.dart'; // Dodali smo uvoz novog layouta

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // OVDJE UBACI SVOJE KLJUČEVE!
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
      title: 'NadjiSat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      // Ovde sada pozivamo glavni navigacioni ekran
      home: const MainLayout(),
    );
  }
}
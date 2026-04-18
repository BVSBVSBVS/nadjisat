import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: Colors.black,
        fontFamily: 'Inter', 
      ),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (Supabase.instance.client.auth.currentSession != null) {
            return const MainLayout();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
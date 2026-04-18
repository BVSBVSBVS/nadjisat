import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true; // Da li smo na ekranu za Prijavu ili Registraciju
  bool isFirma = false; // Checkbox za pravna lica

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  Future<void> _autentifikacija() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final telefon = phoneController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unesite email i lozinku.")));
      return;
    }

    try {
      if (isLogin) {
        // PRIJAVA
        await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      } else {
        // REGISTRACIJA
        if (telefon.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Broj telefona je obavezan za registraciju!")));
          return;
        }
        // Šaljemo i dodatne podatke (telefon i status firme)
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'telefon': telefon,
            'pravno_lice': isFirma,
          }
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uspešna registracija!")));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  void _ulogujKaoGosta() {
    // Propuštamo korisnika bez naloga direktno u aplikaciju!
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Premium siva
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PREMIUM LOGO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.watch, size: 60, color: Colors.orange),
                ),
                const SizedBox(height: 16),
                const Text("NadjiSat", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(isLogin ? "Prijavite se na svoj nalog" : "Kreirajte novi nalog", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 40),

                // FORMA ZA UNOS
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: "Lozinka", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                      ),
                      
                      // DODATNA POLJA SAMO ZA REGISTRACIJU
                      if (!isLogin) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(labelText: "Broj telefona (Obavezno)", prefixIcon: const Icon(Icons.phone_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                        ),
                        const SizedBox(height: 10),
                        CheckboxListTile(
                          title: const Text("Pravno lice (Firma)", style: TextStyle(fontWeight: FontWeight.bold)),
                          activeColor: Colors.orange[700],
                          value: isFirma,
                          onChanged: (val) => setState(() => isFirma = val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],

                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: _autentifikacija,
                        child: Text(isLogin ? "PRIJAVI SE" : "REGISTRUJ SE", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // PREBACIVANJE LOGIN / REGISTRACIJA
                TextButton(
                  onPressed: () => setState(() { isLogin = !isLogin; }),
                  child: Text(isLogin ? "Nemate nalog? Napravite ga ovde" : "Već imate nalog? Prijavite se", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 10),

                // GUEST MODE (SAMO RAZGLEDAM)
                TextButton.icon(
                  onPressed: _ulogujKaoGosta,
                  icon: const Icon(Icons.travel_explore, color: Colors.grey),
                  label: const Text("Samo razgledam (Nastavi bez naloga)", style: TextStyle(color: Colors.grey, fontSize: 15, decoration: TextDecoration.underline)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
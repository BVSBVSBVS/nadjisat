import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OglasiScreen extends StatefulWidget {
  const OglasiScreen({super.key});

  @override
  State<OglasiScreen> createState() => _OglasiScreenState();
}

class _OglasiScreenState extends State<OglasiScreen> {
  final user = Supabase.instance.client.auth.currentUser;

  // Promenljive za formu
  String? izabranBrend;
  String? izabranoStanje;
  String? izabranMaterijal;
  String? izabranoStaklo;
  
  final modelController = TextEditingController();
  final cenaController = TextEditingController();
  final godinaController = TextEditingController();
  final bojaCiferaController = TextEditingController();

  final List<String> brendovi = ['Rolex', 'Omega', 'Seiko', 'Breitling', 'Casio', 'Patek Philippe', 'Audemars Piguet', 'Tissot', 'Longines', 'Tudor'];
  final List<String> stanja = ['Novo (Nenošeno)', 'Odlično (Kao novo)', 'Vrlo dobro', 'Dobro', 'Za delove/Neispravno'];
  final List<String> materijali = ['Čelik', 'Zlato', 'Titanijum', 'Platina', 'Keramika'];
  final List<String> stakla = ['Safirno', 'Mineralno', 'Akrilno (Plexi)'];

  void _prikaziFormu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Da tastatura ne prekrije formu
                left: 16, right: 16, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Dodaj novi sat", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    // PADAJUĆI MENIJI ZA KATEGORIJE
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Brend', border: OutlineInputBorder()),
                      value: izabranBrend,
                      items: brendovi.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (val) => setModalState(() => izabranBrend = val),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: modelController, decoration: const InputDecoration(labelText: 'Model (npr. Submariner)', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: cenaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cena (EUR)', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: godinaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Godina proizvodnje', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Stanje', border: OutlineInputBorder()),
                      value: izabranoStanje,
                      items: stanja.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setModalState(() => izabranoStanje = val),
                    ),
                    const SizedBox(height: 10),
                    
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Materijal kućišta', border: OutlineInputBorder()),
                      value: izabranMaterijal,
                      items: materijali.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setModalState(() => izabranMaterijal = val),
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Staklo', border: OutlineInputBorder()),
                      value: izabranoStaklo,
                      items: stakla.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setModalState(() => izabranoStaklo = val),
                    ),
                    const SizedBox(height: 10),
                    
                    TextField(controller: bojaCiferaController, decoration: const InputDecoration(labelText: 'Boja cifera', border: OutlineInputBorder())),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () async {
                        if (izabranBrend == null || izabranoStanje == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Popunite obavezna polja (Brend i Stanje)")));
                          return;
                        }
                        
                        try {
                          await Supabase.instance.client.from('oglasi').insert({
                            'user_email': user?.email,
                            'brend': izabranBrend,
                            'model': modelController.text.trim(),
                            'cena': int.tryParse(cenaController.text.trim()) ?? 0,
                            'godina': godinaController.text.trim(),
                            'stanje': izabranoStanje,
                            'materijal': izabranMaterijal,
                            'staklo': izabranoStaklo,
                            'boja_cifera': bojaCiferaController.text.trim(),
                            'pregledi': 0,
                            'pratioci': 0,
                          });
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno postavljen!")));
                          }
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
                        }
                      },
                      child: const Text("Postavi oglas", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provera da li je korisnik ulogovan
    if (user == null) {
      return const Center(
        child: Text("Morate da se registrujete da biste postavili oglas.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.watch_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Ovde će biti lista tvojih aktivnih oglasa.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: _prikaziFormu,
              child: const Text("+ DODAJ NOVI OGLAS", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostOglasScreen extends StatefulWidget {
  const PostOglasScreen({super.key});
  @override
  State<PostOglasScreen> createState() => _PostOglasScreenState();
}

class _PostOglasScreenState extends State<PostOglasScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Promenljive
  String? brend, stanje, materijal, staklo;
  final modelController = TextEditingController();
  final cenaController = TextEditingController();
  final godinaController = TextEditingController();

  // Liste za biranje
  final List<String> brendovi = ['Rolex', 'Omega', 'Seiko', 'Breitling', 'Patek Philippe', 'Audemars Piguet', 'Tissot', 'Longines', 'Casio'];
  final List<String> stanja = ['Novo (Nenošeno)', 'Odlično', 'Vrlo dobro', 'Dobro', 'Za delove'];
  final List<String> materijali = ['Čelik', 'Zlato', 'Titanijum', 'Keramika'];
  final List<String> stakla = ['Safirno', 'Mineralno', 'Akrilno'];

  Future<void> _postaviOglas() async {
    if (brend == null || stanje == null || modelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Popuni obavezna polja!")));
      return;
    }
    
    final user = Supabase.instance.client.auth.currentUser;
    try {
      await Supabase.instance.client.from('satovi').insert({
        'user_email': user?.email,
        'brend': brend,
        'model': modelController.text.trim(),
        'cena': int.tryParse(cenaController.text.trim()) ?? 0,
        'godina': godinaController.text.trim(),
        'stanje': stanje,
        'materijal': materijal,
        'staklo': staklo,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno postavljen!")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dodaj novi sat", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Izaberi brend", border: OutlineInputBorder()),
              items: brendovi.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) => setState(() => brend = v),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: modelController, decoration: const InputDecoration(labelText: "Tačan model (npr. Submariner)", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(controller: cenaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cena (€)", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Stanje sata", border: OutlineInputBorder()),
              items: stanja.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => stanje = v),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: godinaController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Godina proizvodnje", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Materijal kućišta", border: OutlineInputBorder()),
              items: materijali.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => materijal = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Tip stakla", border: OutlineInputBorder()),
              items: stakla.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => staklo = v),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.all(16)),
              onPressed: _postaviOglas,
              child: const Text("OBJAVI OGLAS", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
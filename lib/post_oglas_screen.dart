import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostOglasScreen extends StatefulWidget {
  const PostOglasScreen({super.key});
  @override
  State<PostOglasScreen> createState() => _PostOglasScreenState();
}

class _PostOglasScreenState extends State<PostOglasScreen> {
  final _formKey = GlobalKey<FormState>();
  String? brend, model, stanje, materijal, staklo, bojaCifera;
  int? cena, godina;

  Future<void> _postaviOglas() async {
    final user = Supabase.instance.client.auth.currentUser;
    await Supabase.instance.client.from('satovi').insert({
      'brend': brend, 'model': model, 'cena': cena, 'stanje': stanje,
      'godina': godina.toString(), 'materijal': materijal, 'staklo': staklo,
      'boja_cifera': bojaCifera, 'user_email': user?.email
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas postavljen!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novi Oglas")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(decoration: const InputDecoration(labelText: "Brend"), onChanged: (v) => brend = v),
            TextFormField(decoration: const InputDecoration(labelText: "Model"), onChanged: (v) => model = v),
            TextFormField(decoration: const InputDecoration(labelText: "Cena (€)"), keyboardType: TextInputType.number, onChanged: (v) => cena = int.tryParse(v)),
            TextFormField(decoration: const InputDecoration(labelText: "Godina"), keyboardType: TextInputType.number, onChanged: (v) => godina = int.tryParse(v)),
            DropdownButtonFormField(
              hint: const Text("Stanje"),
              items: ["Novo", "Kao novo", "Polovno"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => stanje = v as String,
            ),
            // DODAJ OSTALIH 5 POLJA ISTO OVAKO...
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.all(16)),
              onPressed: _postaviOglas,
              child: const Text("OBJAVI OGLAS", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
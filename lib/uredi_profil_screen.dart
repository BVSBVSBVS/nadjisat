import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UrediProfilScreen extends StatefulWidget {
  const UrediProfilScreen({super.key});

  @override
  State<UrediProfilScreen> createState() => _UrediProfilScreenState();
}

class _UrediProfilScreenState extends State<UrediProfilScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  
  final imeController = TextEditingController();
  final telefonController = TextEditingController();
  bool isFirma = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _ucitajStarePodatke();
  }

  Future<void> _ucitajStarePodatke() async {
    if (user == null) return;
    try {
      final podaci = await Supabase.instance.client.from('profili').select().eq('id', user!.id).maybeSingle();
      if (podaci != null && mounted) {
        setState(() {
          imeController.text = podaci['ime'] ?? podaci['username'] ?? '';
          telefonController.text = podaci['telefon'] ?? '';
          isFirma = podaci['pravno_lice'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Greska: $e");
    }
  }

  Future<void> _sacuvajIzmene() async {
    if (user == null) return;
    setState(() => isSaving = true);
    
    try {
      await Supabase.instance.client.from('profili').update({
        'ime': imeController.text.trim(),
        'telefon': telefonController.text.trim(),
        'pravno_lice': isFirma,
      }).eq('id', user!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil uspešno ažuriran!")));
        Navigator.pop(context); // Vraća na prethodni ekran
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška pri čuvanju: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Uredi Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isSaving 
        ? const Center(child: CupertinoActivityIndicator(radius: 20))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ime i Prezime / Naziv", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: imeController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 20),

                  const Text("Broj telefona", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: telefonController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 20),

                  CheckboxListTile(
                    title: Text("Pravno lice (Firma)", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    activeColor: Colors.blue,
                    value: isFirma,
                    onChanged: (val) => setState(() => isFirma = val ?? false),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                      onPressed: _sacuvajIzmene,
                      child: const Text("Sačuvaj", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
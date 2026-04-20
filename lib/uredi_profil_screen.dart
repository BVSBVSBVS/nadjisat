import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UrediProfilScreen extends StatefulWidget {
  const UrediProfilScreen({super.key});

  @override
  State<UrediProfilScreen> createState() => _UrediProfilScreenState();
}

class _UrediProfilScreenState extends State<UrediProfilScreen> {
  final imeController = TextEditingController();
  final telefonController = TextEditingController();
  final gradController = TextEditingController();
  bool isSaving = false;
  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _ucitajPodatke();
  }

  Future<void> _ucitajPodatke() async {
    if (user == null) return;
    try {
      final data = await Supabase.instance.client.from('profili').select().eq('id', user!.id).maybeSingle();
      if (data != null) {
        setState(() {
          imeController.text = data['ime'] ?? '';
          telefonController.text = data['telefon'] ?? '';
          gradController.text = data['grad'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Greška pri učitavanju profila: $e");
    }
  }

  Future<void> _sacuvajProfil() async {
    if (user == null) return;
    setState(() => isSaving = true);

    try {
      await Supabase.instance.client.from('profili').upsert({
        'id': user!.id,
        'ime': imeController.text.trim(),
        'telefon': telefonController.text.trim(),
        'grad': gradController.text.trim(),
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil uspješno ažuriran!")));
      Navigator.pop(context, true); 
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Uredi profil", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isSaving 
        ? const Center(child: CupertinoActivityIndicator(radius: 20))
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50, backgroundColor: Colors.blue, 
                  child: Icon(Icons.person, size: 50, color: Colors.white)
                ),
              ),
              const SizedBox(height: 30),
              
              const Text("Vaši podaci", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    CupertinoTextField(
                      controller: imeController, placeholder: "Ime i prezime",
                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 15),
                    CupertinoTextField(
                      controller: telefonController, placeholder: "Broj telefona", keyboardType: TextInputType.phone,
                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 15),
                    CupertinoTextField(
                      controller: gradController, placeholder: "Grad (Npr. Beograd)",
                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: CupertinoButton(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                  onPressed: _sacuvajProfil,
                  child: const Text("Sačuvaj izmjene", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ],
          ),
    );
  }
}
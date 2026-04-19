import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_oglas_screen.dart';
import 'main.dart'; // <-- DODALI SMO OVO DA VIDI GLOBALNI PREKIDAČ

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;

  Future<void> _obrisiOglas(String oglasId) async {
    try {
      await Supabase.instance.client.from('satovi').delete().eq('id', oglasId);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno obrisan.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška pri brisanju: $e")));
    }
  }

  void _prikaziOpcijeOglasa(BuildContext context, Map<String, dynamic> oglas, String naslov) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Opcije za "$naslov"'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditOglasScreen(oglas: oglas)));
            },
            child: const Text('Izmeni oglas'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _obrisiOglas(oglas['id'].toString());
            },
            child: const Text('Obriši oglas'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Otkaži'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text("Ulogujte se.")));

    // OVAKO PROVERAVAMO DA LI JE TEMA TRENUTNO TAMNA ILI SVETLA U CELOJ APLIKACIJI
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Automatski prati temu
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Supabase.instance.client.auth.signOut())
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(radius: 40, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 40, color: Colors.white)),
                  const SizedBox(height: 15),
                  Text(user?.email?.split('@')[0] ?? "Korisnik", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  Text(user?.email ?? "", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 18),
                      Text(" 0.0 ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("(0 ocena)", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              // Ako je mrak, stavi tamno sivu karticu, ako je svetlo stavi belu
              decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(CupertinoIcons.moon_fill, color: Colors.purple),
                    title: Text("Dark Mode", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    trailing: CupertinoSwitch(
                      // VREDNOST SADA ČITA IZ MAIN.DART
                      value: isDarkModeGlobal.value,
                      activeTrackColor: Colors.blue,
                      onChanged: (v) {
                        // KADA KLIKNEŠ, OVO JAVLJA MAIN.DART FAJLU DA ZAMRAČI SVE!
                        setState(() {
                          isDarkModeGlobal.value = v;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(CupertinoIcons.person_crop_circle, color: Colors.blue),
                    title: Text("Uredi profil", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Moji oglasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            ),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('satovi').stream(primaryKey: ['id']).eq('user_id', user!.id).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
                if (snapshot.data!.isEmpty) return const Center(child: Text("Nemate aktivnih oglasa.", style: TextStyle(color: Colors.grey)));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final oglas = snapshot.data![index];
                    final naslov = oglas['naslov'] ?? "${oglas['brend']} ${oglas['model']}";

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.watch, color: Colors.grey),
                        title: Text(naslov, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                        subtitle: Text(oglas['cena_dogovor'] == true ? "Po dogovoru" : "${oglas['cena']} €", style: const TextStyle(color: Colors.grey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                          onPressed: () => _prikaziOpcijeOglasa(context, oglas, naslov),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// OVO SU KLJUČNI IMPORTI KOJI SU TI FALILI:
import 'main.dart';
import 'login_screen.dart';
import 'edit_oglas_screen.dart';
import 'oglas_detalji_screen.dart';
import 'uredi_profil_screen.dart';

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
              Navigator.pop(context); // Zatvara opcije
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditOglasScreen(oglas: oglas)));
            },
            child: const Text('Izmeni oglas'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // Zatvara opcije
              _obrisiOglas(oglas['id'].toString()); // Briše oglas
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
    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.lock_circle, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("Niste prijavljeni", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                child: const Text("Prijavi se / Registruj se"),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
              ),
            ],
          ),
        ),
      );
    }

    // OVO JE LINIJA KOJA JE POPRAVILA CRVENU GREŠKU:
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => Supabase.instance.client.auth.signOut())
        ],
      ),
     body: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // OVO JE ISPRAVNO
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(radius: 40, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 40, color: Colors.white)),
                  const SizedBox(height: 15),
                  Text(user?.email?.split('@')[0] ?? "Korisnik", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
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
              decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(CupertinoIcons.moon_fill, color: Colors.purple),
                    title: Text("Dark Mode", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    trailing: CupertinoSwitch(
                      value: isDarkModeGlobal.value,
                      activeColor: Colors.blue,
                      onChanged: (v) {
                        setState(() {
                          isDarkModeGlobal.value = v;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(CupertinoIcons.person_crop_circle, color: Colors.blue),
                    title: Text("Uredi profil", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () async {
                      final rez = await Navigator.push(context, MaterialPageRoute(builder: (context) => const UrediProfilScreen()));
                      if (rez == true) setState(() {});
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Moji oglasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            ),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('satovi').stream(primaryKey: ['id']).eq('user_id', user!.id).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());
                if (snapshot.data!.isEmpty) return const Padding(padding: EdgeInsets.all(20.0), child: Center(child: Text("Nemate aktivnih oglasa.", style: TextStyle(color: Colors.grey))));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final oglas = snapshot.data![index];
                    final naslov = oglas['naslov'] ?? "${oglas['brend']} ${oglas['model']}";

                    return GestureDetector(
                      onTap: () {
                        // KADA KLIKNEŠ OGLAS, OTVARA SE NOVI EKRAN SA DETALJIMA
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OglasDetaljiScreen(oglas: oglas)));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.watch, color: Colors.grey),
                          title: Text(naslov, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                          subtitle: Text(oglas['cena_dogovor'] == true ? "Po dogovoru" : "${oglas['cena']} €", style: const TextStyle(color: Colors.grey)),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                            onPressed: () => _prikaziOpcijeOglasa(context, oglas, naslov),
                          ),
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
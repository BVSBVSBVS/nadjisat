import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  final user = Supabase.instance.client.auth.currentUser;

  // Funkcija za brisanje oglasa
  Future<void> _obrisiOglas(String oglasId) async {
    try {
      await Supabase.instance.client.from('satovi').delete().eq('id', oglasId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno obrisan.")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška pri brisanju: $e")));
      }
    }
  }

  // iOS iskačući meni za opcije oglasa
  void _prikaziOpcijeOglasa(BuildContext context, String oglasId, String naslov) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('Opcije za "$naslov"'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Ovde će ići logika za izmenu oglasa (Uskoro)
            },
            child: const Text('Izmeni oglas'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _obrisiOglas(oglasId);
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
      return const Scaffold(body: Center(child: Text("Ulogujte se da vidite profil.")));
    }

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text("Profil", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF2F2F7),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO SEKCIJA
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
            
            // PODEŠAVANJA
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: isDarkMode ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(CupertinoIcons.moon_fill, color: Colors.purple),
                    title: Text("Dark Mode (Uskoro Globalno)", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    trailing: CupertinoSwitch(
                      value: isDarkMode,
                      activeColor: Colors.blue, // Rešeno upozorenje
                      onChanged: (v) => setState(() => isDarkMode = v),
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

            // MOJI OGLASI LISTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Moji oglasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            ),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('satovi').stream(primaryKey: ['id']).eq('user_id', user!.id).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CupertinoActivityIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: Text("Nemate aktivnih oglasa.", style: TextStyle(color: Colors.grey))),
                  );
                }

                final oglasi = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: oglasi.length,
                  itemBuilder: (context, index) {
                    final oglas = oglasi[index];
                    final naslov = oglas['naslov'] ?? "${oglas['brend']} ${oglas['model']}";

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: isDarkMode ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.watch, color: Colors.grey),
                        title: Text(naslov, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                        subtitle: Text(oglas['cena_dogovor'] == true ? "Po dogovoru" : "${oglas['cena']} €", style: const TextStyle(color: Colors.grey)),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                          onPressed: () => _prikaziOpcijeOglasa(context, oglas['id'].toString(), naslov),
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
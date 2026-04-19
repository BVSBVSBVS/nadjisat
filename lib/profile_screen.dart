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

  // Podaci koje ćemo simulirati dok ne napraviš tabelu 'profiles'
  String ime = "Marko";
  String prezime = "Petrović";
  String username = "@markosatovi";
  double ocena = 4.9;
  int brojOcena = 124;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Ulogujte se da vidite profil.")));
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text("Profil", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
          children: [
            // GORNJI DEO - INFO
            Container(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 50, color: Colors.white)),
                  const SizedBox(height: 15),
                  Text("$ime $prezime", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                  Text(username, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 10),
                  // OCENE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      Text(" $ocena ", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                      Text("($brojOcena ocena)", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // SETTINGS SEKCIJA
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(CupertinoIcons.moon_fill, color: Colors.purple),
                    title: Text("Dark Mode", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    trailing: CupertinoSwitch(
                      value: isDarkMode,
                      onChanged: (v) => setState(() => isDarkMode = v),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(CupertinoIcons.person_crop_circle, color: Colors.blue),
                    title: Text("Uredi profil", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // MOJI OGLASI NASLOV
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text("Moji oglasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                ],
              ),
            ),

            // LISTA OGLASA KORISNIKA
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('satovi')
                  .stream(primaryKey: ['id'])
                  .eq('user_id', user!.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Još uvek niste postavili oglas."),
                  );
                }
                final oglasi = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: oglasi.length,
                  itemBuilder: (context, index) {
                    final o = oglasi[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.watch),
                        title: Text(o['naslov'] ?? "Bez naslova", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                        subtitle: Text("${o['cena'] ?? 'Dogovor'} €"),
                        trailing: const Icon(Icons.edit, size: 20),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
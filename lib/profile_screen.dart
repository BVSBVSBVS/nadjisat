import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; 
// NAPOMENA: Ako ti je ekran za izmenu profila drugacije nazvan, promeni ime ovde ispod:
// import 'uredi_profil_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  Map<String, dynamic>? profilPodaci;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _ucitajProfil();
  }

  Future<void> _ucitajProfil() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final response = await Supabase.instance.client
          .from('profili')
          .select()
          .eq('id', user!.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          profilPodaci = response;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Greska pri ucitavanju profila: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // FUNKCIJA ZA ODJAVU
  Future<void> _odjaviSe() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      // Nasilno brisanje keša i vraćanje na ekran za logovanje!
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.person_crop_circle_badge_xmark, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text("Niste prijavljeni.", style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                child: const Text("Prijavi se"),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Moj Profil", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          // DUGME ZA ODJAVU GORE DESNO
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right, color: Colors.redAccent),
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text("Odjava"),
                  content: const Text("Da li ste sigurni da želite da se odjavite?"),
                  actions: [
                    CupertinoDialogAction(child: const Text("Otkaži"), onPressed: () => Navigator.pop(context)),
                    CupertinoDialogAction(isDestructiveAction: true, onPressed: _odjaviSe, child: const Text("Odjavi se")),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // AVATAR I OSNOVNI INFO
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueAccent.withOpacity(0.2),
                          child: const Icon(CupertinoIcons.person_fill, size: 50, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          profilPodaci?['ime'] ?? profilPodaci?['username'] ?? "Korisnik",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 5),
                        // PRIKAZ EMAIL ADRESE!
                        Text(
                          user!.email ?? "Nema emaila",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        // PRIKAZ OCENA!
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              profilPodaci?['ocena']?.toString() ?? "Nema ocena",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // DETALJI PROFILA U KARTICI
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(CupertinoIcons.phone, color: Colors.green),
                          title: const Text("Telefon"),
                          subtitle: Text(profilPodaci?['telefon'] ?? "Nije unet", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black87)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(CupertinoIcons.building_2_fill, color: Colors.blue),
                          title: const Text("Pravno lice"),
                          subtitle: Text(profilPodaci?['pravno_lice'] == true ? "Da (Firma)" : "Ne (Fizičko lice)", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black87)),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(CupertinoIcons.calendar, color: Colors.orange),
                          title: const Text("Član od"),
                          subtitle: Text(user!.createdAt.split('T')[0], style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black87)), // Prikazuje samo datum
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // DUGME ZA IZMENU PROFILA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      onPressed: () {
                        // OVDE POVEZUJEŠ NA EKRAN ZA IZMENU KAD GA NAPRAVIŠ
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uredi profil uskoro!")));
                      },
                      child: Text("Uredi profil", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // VELIKO CRVENO DUGME ZA ODJAVU DOLE
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      onPressed: _odjaviSe,
                      child: const Text("Odjavi se", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
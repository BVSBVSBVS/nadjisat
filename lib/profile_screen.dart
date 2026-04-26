import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; 
import 'uredi_profil_screen.dart'; 
import 'oglas_detalji_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  Map<String, dynamic>? profilPodaci;
  bool isLoading = true;

  // Liste za oglase i analitiku
  List<Map<String, dynamic>> mojiOglasi = [];
  Map<String, int> preglediOglasa = {};
  Map<String, int> lajkoviOglasa = {};

  @override
  void initState() {
    super.initState();
    _ucitajSve();
  }

  Future<void> _ucitajSve() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      // 1. Ucitaj profil
      final response = await Supabase.instance.client.from('profili').select().eq('id', user!.id).maybeSingle();
      
      // 2. Ucitaj moje oglase (najnoviji prvi)
      final oglasiRes = await Supabase.instance.client.from('satovi').select().eq('user_id', user!.id).order('created_at', ascending: false);
      
      // 3. Za svaki oglas izvuci preglede i lajkove (analitika)
      for (var oglas in oglasiRes) {
        final oglasId = oglas['id'].toString();
        // Koliko ljudi prati
        final lajkoviRes = await Supabase.instance.client.from('praceni_oglasi').select('id').eq('oglas_id', oglasId);
        lajkoviOglasa[oglasId] = lajkoviRes.length;
        // Koliko unikatnih pregleda
        final preglediRes = await Supabase.instance.client.from('pregledi_oglasa').select('id').eq('oglas_id', oglasId);
        preglediOglasa[oglasId] = preglediRes.length;
      }

      if (mounted) {
        setState(() {
          profilPodaci = response;
          mojiOglasi = List<Map<String, dynamic>>.from(oglasiRes);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Greska pri ucitavanju: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _odjaviSe() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  // LOGIKA ZA RAČUNANJE VREMENA (Pre 2 sata, pre 3 dana...)
  String _izracunajVreme(String? isoDate) {
    if (isoDate == null) return "Nepoznato";
    final past = DateTime.parse(isoDate);
    final diff = DateTime.now().difference(past);
    
    if (diff.inDays > 0) return "Postavljen pre ${diff.inDays} d.";
    if (diff.inHours > 0) return "Postavljen pre ${diff.inHours} h.";
    if (diff.inMinutes > 0) return "Postavljen pre ${diff.inMinutes} min.";
    return "Upravo objavljeno";
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
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(user!.email ?? "Nema emaila", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 5),
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

                  // DUGME ZA IZMENU PROFILA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: CupertinoButton(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const UrediProfilScreen())).then((_) => _ucitajSve());
                      },
                      child: Text("Uredi profil", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // SEKCIJA MOJI OGLASI
                  const Text("MOJI OGLASI I ANALITIKA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 15),

                  mojiOglasi.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text("Nemate aktivnih oglasa.", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true, // Zato što je unutar SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mojiOglasi.length,
                        itemBuilder: (context, index) {
                          final oglas = mojiOglasi[index];
                          final oglasId = oglas['id'].toString();
                          
                          // Ekstrakcija prve slike
                          String prvaSlika = "";
                          final slikeStr = oglas['slike']?.toString() ?? "";
                          if (slikeStr.isNotEmpty && slikeStr.length > 5) {
                            prvaSlika = slikeStr.split(',')[0].replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').trim();
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => OglasDetaljiScreen(oglas: oglas)));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[900] : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                              ),
                              child: Row(
                                children: [
                                  // SLIKA SATA
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                                      child: SizedBox(
                                        width: 100, height: 100,
                                        child: (prvaSlika.isNotEmpty && prvaSlika.startsWith('http')) 
                                          ? Image.network(prvaSlika, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey)) 
                                          : const Icon(Icons.watch, color: Colors.grey, size: 40),
                                      ),
                                  ),
                                  // DETALJI I ANALITIKA
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("${oglas['brend']} ${oglas['model']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 5),
                                          Text("${oglas['cena'] ?? 'Dogovor'} €", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 10),
                                          
                                          // ANALITIKA RED (Ikone)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [const Icon(CupertinoIcons.eye_solid, size: 14, color: Colors.grey), const SizedBox(width: 4), Text("${preglediOglasa[oglasId] ?? 0}", style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                                              Row(children: [const Icon(CupertinoIcons.heart_fill, size: 14, color: Colors.redAccent), const SizedBox(width: 4), Text("${lajkoviOglasa[oglasId] ?? 0}", style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                                              Row(children: [const Icon(CupertinoIcons.clock_fill, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(_izracunajVreme(oglas['created_at']), style: const TextStyle(fontSize: 10, color: Colors.grey))]),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                ],
              ),
            ),
    );
  }
}
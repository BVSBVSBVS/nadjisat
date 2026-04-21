import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'oglas_detalji_screen.dart';

class PraceniScreen extends StatefulWidget {
  const PraceniScreen({super.key});

  @override
  State<PraceniScreen> createState() => _PraceniScreenState();
}

class _PraceniScreenState extends State<PraceniScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  List<Map<String, dynamic>> praceniSatovi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _ucitajPracene();
  }

  Future<void> _ucitajPracene() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // 1. Nalazimo sve ID-jeve koje korisnik prati
      final praceniRes = await Supabase.instance.client
          .from('praceni_oglasi')
          .select('oglas_id')
          .eq('user_id', user!.id);

      if (praceniRes.isEmpty) {
        setState(() {
          praceniSatovi = [];
          isLoading = false;
        });
        return;
      }

      // 2. Pretvaramo ih u String listu
      final List<String> oglasIds = praceniRes.map((e) => e['oglas_id'].toString()).toList();

      // 3. Skidamo te oglase iz tabele satovi
      final satoviRes = await Supabase.instance.client
          .from('satovi')
          .select()
          .inFilter('id', oglasIds);

      if (mounted) {
        setState(() {
          praceniSatovi = List<Map<String, dynamic>>.from(satoviRes);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Greska: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _ukloniIzPracenih(String oglasId) async {
    if (user == null) return;
    
    setState(() {
      praceniSatovi.removeWhere((sat) => sat['id'].toString() == oglasId);
    });

    try {
      await Supabase.instance.client
          .from('praceni_oglasi')
          .delete()
          .eq('user_id', user!.id)
          .eq('oglas_id', oglasId);
    } catch (e) {
      _ucitajPracene(); // Vrati ako baza odbije
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // MAGIJA ZA RESPONSIVE EKRAN (6 na PC-u, 2 na fonu)
    final screenWidth = MediaQuery.of(context).size.width;
    int brojKolona = 2; 
    if (screenWidth > 1200) {
      brojKolona = 6; 
    } else if (screenWidth > 900) {
      brojKolona = 4; 
    } else if (screenWidth > 600) {
      brojKolona = 3; 
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Praćeni Oglasi", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: isLoading 
        ? const Center(child: CupertinoActivityIndicator())
        : praceniSatovi.isEmpty
          ? const Center(child: Text("Nemate praćenih oglasa.", style: TextStyle(color: Colors.grey, fontSize: 16)))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: brojKolona, 
                crossAxisSpacing: 12, 
                mainAxisSpacing: 12, 
                childAspectRatio: 0.72
              ),
              itemCount: praceniSatovi.length,
              itemBuilder: (context, index) {
                final sat = praceniSatovi[index];
                final oglasId = sat['id'].toString();
                final slikeStr = sat['slike']?.toString() ?? "";
                
                String? prvaSlika;
                if (slikeStr.isNotEmpty && slikeStr.length > 5) {
                   prvaSlika = slikeStr.split(',')[0].replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').trim();
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OglasDetaljiScreen(oglas: sat)));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white, 
                      borderRadius: BorderRadius.circular(15), 
                      boxShadow: [BoxShadow(color: isDark ? Colors.black54 : Colors.black12, blurRadius: 8, offset: const Offset(0, 4))]
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                child: Container(
                                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                                  width: double.infinity,
                                  child: (prvaSlika != null && prvaSlika.startsWith('http')) 
                                      ? Image.network(
                                          prvaSlika, 
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                        ) 
                                      : const Icon(Icons.watch, size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(sat['cena_dogovor'] == true ? "Po dogovoru" : "${sat['cena'] ?? '0'} €", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? Colors.white : Colors.black)),
                                  const SizedBox(height: 2),
                                  Text("${sat['brend'] ?? 'Nepoznat'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent)),
                                  Text("${sat['model'] ?? ''}", style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            )
                          ],
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _ukloniIzPracenih(oglasId),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: isDark ? Colors.black54 : Colors.white70, shape: BoxShape.circle),
                              child: const Icon(CupertinoIcons.heart_fill, color: Colors.red, size: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
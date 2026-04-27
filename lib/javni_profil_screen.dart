import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JavniProfilScreen extends StatefulWidget {
  final String prodavacId;
  const JavniProfilScreen({super.key, required this.prodavacId});

  @override
  State<JavniProfilScreen> createState() => _JavniProfilScreenState();
}

class _JavniProfilScreenState extends State<JavniProfilScreen> {
  Map<String, dynamic>? profil;
  List<dynamic> ocene = [];
  bool isLoading = true;

  int ukupnoOcena = 0;
  double prosecnaOcena = 0.0;
  Map<int, int> raspodelaOcena = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

  @override
  void initState() {
    super.initState();
    _ucitajProfilIOcene();
  }

  Future<void> _ucitajProfilIOcene() async {
    try {
      final p = await Supabase.instance.client.from('profili').select().eq('id', widget.prodavacId).maybeSingle();
      final o = await Supabase.instance.client.from('ocene').select('*, satovi(brend, model)').eq('ocenjeni_id', widget.prodavacId).order('created_at', ascending: false);

      ukupnoOcena = o.length;
      if (ukupnoOcena > 0) {
        double zbir = 0;
        for (var ocena in o) {
          int vrednost = ocena['vrednost'] ?? 5;
          zbir += vrednost;
          raspodelaOcena[vrednost] = (raspodelaOcena[vrednost] ?? 0) + 1;
        }
        prosecnaOcena = zbir / ukupnoOcena;
      }

      if (mounted) {
        setState(() {
          profil = p;
          ocene = o;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Greška pri učitavanju tuđeg profila: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildStatBar(int zvezdice, int broj, int ukupno, bool isDark) {
    double procenat = ukupno > 0 ? (broj / ukupno) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$zvezdice", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
          const Icon(Icons.star, color: Colors.amber, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: procenat,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                color: Colors.amber,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text("$broj", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAnketaRed(String pitanje, bool odgovor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(odgovor ? CupertinoIcons.checkmark_alt_circle_fill : CupertinoIcons.xmark_circle_fill, size: 14, color: odgovor ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(pitanje, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700])),
          const Spacer(),
          Text(odgovor ? "Da" : "Ne", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: odgovor ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor, body: const Center(child: CupertinoActivityIndicator()));
    if (profil == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text("Profil ne postoji.")));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(profil?['ime'] ?? profil?['username'] ?? "Korisnik", style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 40, backgroundColor: Colors.blueAccent.withOpacity(0.2), child: const Icon(CupertinoIcons.person_fill, size: 40, color: Colors.blueAccent)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profil?['ime'] ?? profil?['username'] ?? "Korisnik", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(profil?['pravno_lice'] == true ? "Firma (Pravno lice)" : "Fizičko lice", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(CupertinoIcons.calendar, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("Na sajtu od: ${profil?['created_at']?.split('T')[0] ?? 'Nepoznato'}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),

            const Text("Ocene korisnika", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.2))),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(prosecnaOcena.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
                      Row(
                        children: List.generate(5, (index) => Icon(index < prosecnaOcena.round() ? Icons.star : Icons.star_border, color: Colors.amber, size: 16)),
                      ),
                      const SizedBox(height: 5),
                      Text("$ukupnoOcena ocena", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildStatBar(5, raspodelaOcena[5]!, ukupnoOcena, isDark),
                        _buildStatBar(4, raspodelaOcena[4]!, ukupnoOcena, isDark),
                        _buildStatBar(3, raspodelaOcena[3]!, ukupnoOcena, isDark),
                        _buildStatBar(2, raspodelaOcena[2]!, ukupnoOcena, isDark),
                        _buildStatBar(1, raspodelaOcena[1]!, ukupnoOcena, isDark),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("Sve ocene i komentari", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            if (ocene.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Korisnik još nema nijednu ocenu.", style: TextStyle(color: Colors.grey))))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ocene.length,
                itemBuilder: (context, index) {
                  final o = ocene[index];
                  int zvezdice = o['vrednost'] ?? 5;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: List.generate(5, (i) => Icon(i < zvezdice ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
                            Text(o['created_at']?.split('T')[0] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        
                        const SizedBox(height: 5),

                        Text(
                          o['satovi'] != null ? "Sat: ${o['satovi']['brend']} ${o['satovi']['model']}" : "Oglas je u međuvremenu obrisan",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 13),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        _buildAnketaRed("Opis tačan:", o['opis_tacan'] == true, isDark),
                        _buildAnketaRed("Korektna komunikacija:", o['komunikacija_korektna'] == true, isDark),
                        _buildAnketaRed("Stanje ispoštovano:", o['stanje_tacno'] == true, isDark),

                        // PRIKAZ KOMENTARA KUPCA
                        if (o['komentar'] != null && o['komentar'].toString().trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.withOpacity(0.2))
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(CupertinoIcons.quote_bubble, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('"${o['komentar']}"', style: TextStyle(fontStyle: FontStyle.italic, color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 14)),
                                ),
                              ],
                            ),
                          )
                        ]
                      ],
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
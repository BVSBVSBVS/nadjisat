import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // NOVI ALAT ZA POZIVE I PORUKE

class OglasDetaljiScreen extends StatefulWidget {
  final Map<String, dynamic> oglas;
  const OglasDetaljiScreen({super.key, required this.oglas});

  @override
  State<OglasDetaljiScreen> createState() => _OglasDetaljiScreenState();
}

class _OglasDetaljiScreenState extends State<OglasDetaljiScreen> {
  int _trenutnaSlika = 0;
  String telefonProdavca = ""; // Čuvaćemo broj ovde da bi ga donja dugmad koristila

  // --- FUNKCIJE ZA KONTAKT ---

  // 1. Običan poziv
  Future<void> _pozoviBroj() async {
    if (telefonProdavca.isEmpty) return;
    final Uri url = Uri.parse('tel:$telefonProdavca');
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ne mogu da pokrenem poziv')));
    }
  }

  // 2. Običan SMS (sa unapred napisanim tekstom)
  Future<void> _posaljiSMS(String naslovOglasa) async {
    if (telefonProdavca.isEmpty) return;
    // Pravimo poruku koja odmah piše za koji sat se kupac javlja
    final poruka = Uri.encodeComponent("Zdravo, pišem povodom oglasa na NadjiSat za: $naslovOglasa.");
    final Uri url = Uri.parse('sms:$telefonProdavca?body=$poruka');
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ne mogu da otvorim SMS')));
    }
  }

  // 3. WhatsApp
  Future<void> _otvoriWhatsApp(String naslovOglasa) async {
    if (telefonProdavca.isEmpty) return;
    // Čistimo broj (skidamo pluseve, razmake, minuse jer WA trazi čist broj tipa 38164...)
    String cistBroj = telefonProdavca.replaceAll(RegExp(r'[^0-9]'), '');
    final poruka = Uri.encodeComponent("Zdravo, pišem povodom oglasa na NadjiSat za: $naslovOglasa.");
    final Uri url = Uri.parse('https://wa.me/$cistBroj?text=$poruka');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp nije instaliran')));
    }
  }

  // 4. Viber (Viber ima specifičan URL format)
  Future<void> _otvoriViber() async {
    if (telefonProdavca.isEmpty) return;
    String cistBroj = telefonProdavca.replaceAll(RegExp(r'[^0-9+]'), ''); // Viber obično voli +
    final Uri url = Uri.parse('viber://chat?number=$cistBroj');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viber nije instaliran')));
    }
  }

  Widget _buildSpecRed(String naslov, String? vrednost, bool isDark) {
    if (vrednost == null || vrednost.isEmpty || vrednost == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(naslov, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(vrednost, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final oglas = widget.oglas;
    
    final slikeStr = oglas['slike']?.toString() ?? "";
    final List<String> slike = slikeStr.isNotEmpty ? slikeStr.split(',') : [];
    final naslovSata = "${oglas['brend']} ${oglas['model']}";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(naslovSata, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (slike.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 350,
                    child: PageView.builder(
                      itemCount: slike.length,
                      onPageChanged: (index) => setState(() => _trenutnaSlika = index),
                      itemBuilder: (context, index) {
                        return Image.network(slike[index], fit: BoxFit.cover);
                      },
                    ),
                  ),
                  if (slike.length > 1)
                    Positioned(
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                        child: Text("${_trenutnaSlika + 1} / ${slike.length}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(oglas['naslov'] ?? "Sat", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  Text(
                    oglas['cena_dogovor'] == true ? "Cena po dogovoru" : "${oglas['cena']} ${oglas['valuta'] ?? '€'}", 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blue)
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.location_solid, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(oglas['lokacija'] ?? "Lokacija nije navedena", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // --- KARTICA PRODAVCA ---
                  const Text("INFORMACIJE O PRODAVCU", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: Supabase.instance.client.from('profili').select().eq('id', oglas['user_id']).maybeSingle(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CupertinoActivityIndicator());
                      }
                      
                      final prodavac = snapshot.data ?? {};
                      final ime = prodavac['ime'] ?? prodavac['username'] ?? "Korisnik";
                      final telefon = prodavac['telefon'] ?? "";
                      final ocena = prodavac['ocena']?.toString() ?? "Nema ocena"; 

                      // Čuvamo telefon u state-u da bi donja dugmad mogla da ga koriste
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && telefonProdavca != telefon) {
                          setState(() => telefonProdavca = telefon);
                        }
                      });

                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                                  child: const Icon(CupertinoIcons.person_fill, color: Colors.blueAccent),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ime, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(ocena, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.phone_fill, color: Colors.green, size: 18),
                                const SizedBox(width: 10),
                                Text(telefon.isNotEmpty ? telefon : "Nije unet broj", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                color: Colors.transparent,
                                child: const Text("Vidi ceo profil", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ovo će otvoriti profil prodavca!")));
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  ),

                  const SizedBox(height: 25),
                  const Text("Detalji", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                    child: Column(
                      children: [
                        _buildSpecRed("Brend", oglas['brend'], isDark),
                        _buildSpecRed("Model", oglas['model'], isDark),
                        _buildSpecRed("Ref. broj", oglas['ref_broj'], isDark),
                        _buildSpecRed("Godina", oglas['godina'], isDark),
                        const Divider(height: 20),
                        _buildSpecRed("Stanje", oglas['stanje'], isDark),
                        _buildSpecRed("Kutija", oglas['originalna_kutija'] == true ? "Da" : "Ne", isDark),
                        _buildSpecRed("Papiri", oglas['originalni_papiri'] == true ? "Da" : "Ne", isDark),
                        _buildSpecRed("Garancija", oglas['garancija'], isDark),
                        const Divider(height: 20),
                        _buildSpecRed("Mehanizam", oglas['mehanizam'], isDark),
                        _buildSpecRed("Prečnik", oglas['precnik'], isDark),
                        _buildSpecRed("Lug-to-Lug", oglas['lug_to_lug'], isDark),
                        _buildSpecRed("Materijal", oglas['materijal'], isDark),
                        _buildSpecRed("Narukvica", oglas['materijal_narukvice'], isDark),
                        _buildSpecRed("Cifer", oglas['boja_brojcanika'], isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  if (oglas['opis'] != null && oglas['opis'].toString().isNotEmpty) ...[
                    const Text("Opis prodavca", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(oglas['opis'], style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[300] : Colors.grey[800], height: 1.5)),
                    const SizedBox(height: 25),
                  ],

                  if (oglas['zamena'] == true)
                    Container(
                      padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Row(children: [Icon(CupertinoIcons.arrow_right_arrow_left, color: Colors.orange), SizedBox(width: 10), Text("Moguća zamena", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))]),
                    ),
                  if (oglas['servisna_istorija'] != null && oglas['servisna_istorija'].toString().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [const Icon(CupertinoIcons.wrench_fill, color: Colors.green), const SizedBox(width: 10), Expanded(child: Text("Servis: ${oglas['servisna_istorija']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // --- MODERAN DONJI MENI ZA KONTAKT ---
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: telefonProdavca.isEmpty 
            ? const Text("Broj prodavca nije dostupan", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
            : Row(
                children: [
                  // DUGME ZA POZIV (Glavno)
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _pozoviBroj,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.phone_fill, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Pozovi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // DUGMAD ZA SMS, WHATSAPP, VIBER
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _maloKontaktDugme(CupertinoIcons.chat_bubble_text_fill, Colors.blueAccent, () => _posaljiSMS(naslovSata)),
                        _maloKontaktDugme(Icons.wechat, const Color(0xFF25D366), () => _otvoriWhatsApp(naslovSata)), // WhatsApp zelena
                        _maloKontaktDugme(Icons.phone_in_talk, const Color(0xFF7360F2), _otvoriViber), // Viber ljubičasta
                      ],
                    ),
                  )
                ],
              ),
        ),
      ),
    );
  }

  // Pomoćni widget za ona mala okrugla dugmad (SMS, WA, Viber)
  Widget _maloKontaktDugme(IconData ikona, Color boja, VoidCallback onKlik) {
    return GestureDetector(
      onTap: onKlik,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: boja.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(ikona, color: boja, size: 24),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_oglas_screen.dart'; // Ili kako god da ti se tačno zove fajl
import 'javni_profil_screen.dart';

class OglasDetaljiScreen extends StatefulWidget {
  final Map<String, dynamic> oglas;
  const OglasDetaljiScreen({super.key, required this.oglas});

  @override
  State<OglasDetaljiScreen> createState() => _OglasDetaljiScreenState();
}

class _OglasDetaljiScreenState extends State<OglasDetaljiScreen> {
  int _trenutnaSlika = 0;
  String telefonProdavca = "";
  final trenutniKorisnik = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _zabeleziUnikatniPregled();
  }

  Future<void> _zabeleziUnikatniPregled() async {
    final oglasId = widget.oglas['id'];
    final vlasnikId = widget.oglas['user_id'];
    if (trenutniKorisnik == null || trenutniKorisnik?.id == vlasnikId) return;
    try {
      await Supabase.instance.client.from('pregledi_oglasa').insert({'oglas_id': oglasId, 'user_id': trenutniKorisnik!.id});
    } catch (_) {}
  }

  // --- FUNKCIJE ZA VLASNIKA OGLASA ---
  
  Future<void> _obrisiOglas() async {
    try {
      // Brišemo oglas iz Supabase baze!
      await Supabase.instance.client.from('satovi').delete().eq('id', widget.oglas['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas je uspešno obrisan!")));
        Navigator.pop(context); // Vraća te nazad na prethodni ekran
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška pri brisanju: $e")));
    }
  }

  void _prikaziPotvrduBrisanja() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Obriši oglas"),
        content: const Text("Da li ste sigurni da želite da trajno obrišete ovaj oglas?"),
        actions: [
          CupertinoDialogAction(child: const Text("Otkaži"), onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(isDestructiveAction: true, onPressed: () { Navigator.pop(context); _obrisiOglas(); }, child: const Text("Obriši")),
        ],
      ),
    );
  }

 void _idiNaIzmenuOglasa() async {
    final bool? izmenjeno = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IzmeniOglasScreen(oglas: widget.oglas)),
    );

    if (izmenjeno == true && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OglasDetaljiScreen(oglas: widget.oglas)),
      );
    }
  }

  // --- FUNKCIJE ZA KONTAKT (ZA KUPCE) ---

  Future<void> _pozoviBroj() async {
    if (telefonProdavca.isEmpty) return;
    final Uri url = Uri.parse('tel:$telefonProdavca');
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ne mogu da pokrenem poziv')));
    }
  }

  Future<void> _posaljiSMS(String naslovOglasa) async {
    if (telefonProdavca.isEmpty) return;
    final poruka = Uri.encodeComponent("Zdravo, pišem povodom oglasa na NadjiSat za: $naslovOglasa.");
    final Uri url = Uri.parse('sms:$telefonProdavca?body=$poruka');
    if (!await launchUrl(url)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ne mogu da otvorim SMS')));
    }
  }

  Future<void> _otvoriWhatsApp(String naslovOglasa) async {
    if (telefonProdavca.isEmpty) return;
    String cistBroj = telefonProdavca.replaceAll(RegExp(r'[^0-9]'), '');
    final poruka = Uri.encodeComponent("Zdravo, pišem povodom oglasa na NadjiSat za: $naslovOglasa.");
    final Uri url = Uri.parse('https://wa.me/$cistBroj?text=$poruka');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp nije instaliran')));
    }
  }

  Future<void> _otvoriViber() async {
    if (telefonProdavca.isEmpty) return;
    String cistBroj = telefonProdavca.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri url = Uri.parse('viber://chat?number=$cistBroj');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viber nije instaliran')));
    }
  }

  Future<void> _oceniProdavca(String prodavacId, int zvezdice) async {
    if (trenutniKorisnik == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Morate biti prijavljeni da biste ocenili.")));
      return;
    }
    if (trenutniKorisnik!.id == prodavacId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ne možete oceniti sami sebe!")));
      return;
    }
    try {
      await Supabase.instance.client.from('ocene').delete().eq('ocenjivac_id', trenutniKorisnik!.id).eq('ocenjeni_id', prodavacId);
      await Supabase.instance.client.from('ocene').insert({'ocenjivac_id': trenutniKorisnik!.id, 'ocenjeni_id': prodavacId, 'vrednost': zvezdice});
      final res = await Supabase.instance.client.from('ocene').select('vrednost').eq('ocenjeni_id', prodavacId);
      if (res.isNotEmpty) {
        double zbir = 0;
        for (var r in res) { zbir += (r['vrednost'] as num).toDouble(); }
        double prosek = zbir / res.length;
        await Supabase.instance.client.from('profili').update({'ocena': prosek.toStringAsFixed(1)}).eq('id', prodavacId);
      }
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uspešno ste ocenili prodavca!")));
         setState((){}); 
      }
    } catch(e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška pri ocenjivanju: $e")));
    }
  }

  void _prikaziDijalogZaOcenu(String prodavacId) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        int odabranaOcena = 5;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return CupertinoAlertDialog(
              title: const Text("Oceni prodavca"),
              content: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setDialogState(() => odabranaOcena = index + 1),
                        child: Icon(index < odabranaOcena ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(child: const Text("Otkaži"), onPressed: () => Navigator.pop(context)),
                CupertinoDialogAction(
                  child: const Text("Oceni", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context);
                    _oceniProdavca(prodavacId, odabranaOcena);
                  },
                ),
              ],
            );
          }
        );
      }
    );
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

    // PROVERA DA LI JE OVO MOJ OGLAS
    final bool jeMojOglas = trenutniKorisnik?.id == oglas['user_id'];

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
                  
                  // KARTICA PRODAVCA - Ako je moj oglas, sakrivamo ocenjivanje prodavca jer ne mogu da ocenjujem sebe
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
                            
                            // Ne pokazujemo dugme za ocenu ako smo na sopstvenom oglasu!
                            if (!jeMojOglas) ...[
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
  child: CupertinoButton(
    padding: const EdgeInsets.symmetric(vertical: 10),
    color: Colors.transparent,
    child: const Text("Vidi profil", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
    onPressed: () {
      // PREBACUJE NA NOVI EKRAN JAVNOG PROFILA I ŠALJE ID PRODAVCA
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JavniProfilScreen(prodavacId: oglas['user_id'])),
      );
    },
  ),
),
                                    Container(width: 1, height: 20, color: Colors.grey.withOpacity(0.3)), 
                                    Expanded(
                                      child: CupertinoButton(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        color: Colors.transparent,
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.star, color: Colors.amber, size: 16),
                                            SizedBox(width: 5),
                                            Text("Oceni", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        onPressed: () => _prikaziDijalogZaOcenu(oglas['user_id']),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ]
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
                ],
              ),
            ),
          ],
        ),
      ),
      
      // MENI NA DNU - PREPOZNAJE DA LI JE TVOJ OGLAS ILI TUĐI
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: jeMojOglas 
            // AKO JE OVO MOJ OGLAS - PRIKAŽI IZMENI I OBRIŠI
            ? Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _idiNaIzmenuOglasa,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.pencil, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Izmeni oglas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _prikaziPotvrduBrisanja,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.trash, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text("Obriši oglas", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            // AKO NIJE MOJ OGLAS - PRIKAŽI POZIV I PORUKE
            : telefonProdavca.isEmpty 
              ? const Text("Broj prodavca nije dostupan", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))
              : Row(
                  children: [
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
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _maloKontaktDugme(CupertinoIcons.chat_bubble_text_fill, Colors.blueAccent, () => _posaljiSMS(naslovSata)),
                          _maloKontaktDugme(Icons.wechat, const Color(0xFF25D366), () => _otvoriWhatsApp(naslovSata)), 
                          _maloKontaktDugme(Icons.phone_in_talk, const Color(0xFF7360F2), _otvoriViber), 
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

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
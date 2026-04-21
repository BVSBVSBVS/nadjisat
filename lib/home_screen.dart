import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'oglas_detalji_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String pretragaText = '';
  final user = Supabase.instance.client.auth.currentUser;
  
  // POPRAVLJENO: ID je sada String (tekst), a ne int (broj)!
  Set<String> praceniOglasiIds = {};

  String? filterBrend, filterModel, filterStanje, filterMaterijal, filterMehanizam, filterNamena, filterPrecnik, filterMaterijalNarukvice, filterBojaBrojcanika, filterGarancija;
  bool? filterKutija;
  bool? filterPapiri;
  final minCenaController = TextEditingController();
  final maxCenaController = TextEditingController();

  final Map<String, List<String>> brendoviIModeli = {
    'Svi': [],
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Explorer', 'Day-Date', 'Sea-Dweller'],
    'Omega': ['Speedmaster', 'Seamaster', 'Constellation', 'De Ville', 'Aqua Terra'],
    'Seiko': ['Prospex', 'Presage', 'Astron', '5 Sports', 'King Seiko', 'Premier'],
    'TAG Heuer': ['Carrera', 'Monaco', 'Aquaracer', 'Formula 1', 'Autavia'],
    'Casio': ['G-Shock', 'Edifice', 'Pro Trek', 'Baby-G', 'Vintage'],
  };

  final List<String> namene = ['Sve', 'Dres (Dress)', 'Ronilački (Diver)', 'Hronograf (Chronograph)', 'Pilot (Aviator)', 'Sportski/GADA', 'Luksuzni', 'Smartwatch'];
  final List<String> mehanizmi = ['Sve', 'Automatik', 'Manuelni', 'Kvarcni', 'Spring Drive', 'Solar', 'Kinetic'];
  final List<String> precnici = ['Sve', 'Do 34mm', '36mm', '38mm', '40mm', '42mm', '44mm', '46mm+'];
  final List<String> materijali = ['Sve', 'Čelik', 'Zlato (18k)', 'Titanijum', 'Platina', 'Keramika', 'Bronza', 'Guma/Plastika'];
  final List<String> materijaliNarukvice = ['Sve', 'Čelik', 'Koža', 'Guma', 'Tekstil/Nato', 'Titanijum', 'Zlato'];
  final List<String> bojeBrojcanika = ['Sve', 'Crna', 'Plava', 'Bela/Srebrna', 'Zelena', 'Siva', 'Zlatna', 'Druga'];
  final List<String> stanja = ['Sve', '1. Novo sa folijama', '2. Kao novo', '3. Odlično', '4. Dobro', '5. Vidljivi tragovi korišćenja'];
  final List<String> opcijeGarancije = ['Sve', 'Nema garanciju', 'Radna garancija', '1 godina', '2+ godine', 'Važeća fabrička'];

  @override
  void initState() {
    super.initState();
    _ucitajPracene();
  }

  Future<void> _ucitajPracene() async {
    if (user == null) return;
    try {
      final response = await Supabase.instance.client.from('praceni_oglasi').select('oglas_id').eq('user_id', user!.id);
      if (mounted) {
        setState(() {
          // POPRAVLJENO: Čitamo ID kao String
          praceniOglasiIds = response.map((e) => e['oglas_id'].toString()).toSet();
        });
      }
    } catch (e) {
      debugPrint("Greska pri ucitavanju pracenih: $e");
    }
  }

  // POPRAVLJENO: oglasId je sada String
  Future<void> _togglePraceni(String oglasId) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Morate biti prijavljeni da biste pratili oglase.")));
      return;
    }

    final isPracen = praceniOglasiIds.contains(oglasId);

    setState(() {
      if (isPracen) praceniOglasiIds.remove(oglasId);
      else praceniOglasiIds.add(oglasId);
    });

    try {
      if (isPracen) {
        await Supabase.instance.client.from('praceni_oglasi').delete().eq('user_id', user!.id).eq('oglas_id', oglasId);
      } else {
        await Supabase.instance.client.from('praceni_oglasi').insert({'user_id': user!.id, 'oglas_id': oglasId});
      }
    } catch (e) {
      setState(() {
        if (isPracen) praceniOglasiIds.add(oglasId);
        else praceniOglasiIds.remove(oglasId);
      });
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  void _prikaziIOSPicker(String naslov, List<String> opcije, Function(String) onOdabrano) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Container(
              height: 50,
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(child: const Text('Gotovo'), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (index) => onOdabrano(opcije[index]),
                children: opcije.map((o) => Center(child: Text(o, style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iosFilterDugme(String label, String? vrednost, List<String> opcije, Function(String) onOdabrano) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _prikaziIOSPicker(label, opcije, onOdabrano),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(child: Text(vrednost ?? "Sve", overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500))),
                  const SizedBox(width: 5),
                  const Icon(CupertinoIcons.chevron_down, size: 16, color: Colors.grey),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _otvoriFiltere() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text("Svi Filteri", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 20),

              _iosFilterDugme("Brend", filterBrend, brendoviIModeli.keys.toList(), (v) => setState(() { filterBrend = v == 'Svi' ? null : v; filterModel = null; })),
              if (filterBrend != null && brendoviIModeli[filterBrend] != null)
                _iosFilterDugme("Model", filterModel, ['Svi', ...brendoviIModeli[filterBrend]!], (v) => setState(() => filterModel = v == 'Svi' ? null : v)),
              
              const SizedBox(height: 15),
              const Text("CENA (€)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: CupertinoTextField(style: TextStyle(color: isDark ? Colors.white : Colors.black), controller: minCenaController, placeholder: "Od", keyboardType: TextInputType.number, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(width: 10),
                  Expanded(child: CupertinoTextField(style: TextStyle(color: isDark ? Colors.white : Colors.black), controller: maxCenaController, placeholder: "Do", keyboardType: TextInputType.number, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[100], borderRadius: BorderRadius.circular(10)))),
                ],
              ),
              const SizedBox(height: 15),

              _iosFilterDugme("Kategorija / Namjena", filterNamena, namene, (v) => setState(() => filterNamena = v == 'Sve' ? null : v)),
              _iosFilterDugme("Stanje", filterStanje, stanja, (v) => setState(() => filterStanje = v == 'Sve' ? null : v)),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () { setState(() {}); Navigator.pop(context); },
                  child: const Text("Pretraži", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("NadjiSat", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    placeholder: "Pretraži oglase...",
                    onChanged: (v) => setState(() => pretragaText = v.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _otvoriFiltere,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Icon(CupertinoIcons.slider_horizontal_3, color: isDark ? Colors.white : Colors.black),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client.from('satovi').stream(primaryKey: ['id']).order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CupertinoActivityIndicator());

                final satovi = snapshot.data!.where((sat) {
                  final naslov = (sat['naslov'] ?? '').toString().toLowerCase();
                  if (pretragaText.isNotEmpty && !naslov.contains(pretragaText)) return false;
                  return true;
                }).toList();

                if (satovi.isEmpty) return const Center(child: Text("Nema rezultata.", style: TextStyle(color: Colors.grey)));

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                  itemCount: satovi.length,
                  itemBuilder: (context, index) {
                    final sat = satovi[index];
                    
                    // OVO JE BILA GREŠKA! Sada je id ispravno tretiran kao tekst.
                    final oglasId = sat['id'].toString(); 
                    
                    final slikeStr = sat['slike']?.toString() ?? "";
                    
                    // Sigurnosno čišćenje linka slike
                    String? prvaSlika;
                    if (slikeStr.isNotEmpty && slikeStr.length > 5) {
                       prvaSlika = slikeStr.split(',')[0].replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').trim();
                    }
                    
                    final isPracen = praceniOglasiIds.contains(oglasId);

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
                                      // PANCIR: Pokazuje sliku, ako pukne pokazuje ikonicu
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
                                onTap: () => _togglePraceni(oglasId),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: isDark ? Colors.black54 : Colors.white70, shape: BoxShape.circle),
                                  child: Icon(isPracen ? CupertinoIcons.heart_fill : CupertinoIcons.heart, color: isPracen ? Colors.red : (isDark ? Colors.white : Colors.black87), size: 20),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
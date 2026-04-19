import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String pretragaText = '';
  
  String? filterBrend, filterModel, filterStanje, filterMaterijal, filterStaklo, filterMehanizam, filterVodootpornost, filterKutija;
  final minCenaController = TextEditingController();
  final maxCenaController = TextEditingController();
  final minGodinaController = TextEditingController();
  final maxGodinaController = TextEditingController();

  final Map<String, List<String>> brendoviIModeli = {
    'Svi': [],
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Oyster Perpetual', 'Sea-Dweller', 'Yacht-Master', 'Sky-Dweller', 'Explorer', 'Milgauss'],
    'Omega': ['Speedmaster', 'Seamaster', 'Aqua Terra', 'Planet Ocean', 'De Ville', 'Constellation', 'Railmaster'],
    'Patek Philippe': ['Nautilus', 'Aquanaut', 'Calatrava', 'Complications', 'Grand Complications', 'Gondolo', 'Ellipse'],
    'Audemars Piguet': ['Royal Oak', 'Royal Oak Offshore', 'Code 11.59', 'Millenary', 'Jules Audemars'],
    'Vacheron Constantin': ['Overseas', 'Patrimony', 'Traditionnelle', 'Fiftysix', 'Historiques'],
    'Richard Mille': ['RM 011', 'RM 035', 'RM 055', 'RM 067', 'RM 11-03'],
    'Cartier': ['Santos', 'Tank', 'Ballon Bleu', 'Pasha', 'Panthere', 'Drive de Cartier'],
    'IWC': ['Portugieser', 'Pilot', 'Portofino', 'Aquatimer', 'Ingenieur', 'Da Vinci'],
    'Breitling': ['Navitimer', 'Superocean', 'Chronomat', 'Avenger', 'Endurance Pro', 'Premier'],
    'Tudor': ['Black Bay', 'Pelagos', 'Ranger', '1926', 'Royal'],
    'Panerai': ['Luminor', 'Radiomir', 'Submersible', 'Luminor Due'],
    'Hublot': ['Big Bang', 'Classic Fusion', 'Spirit of Big Bang'],
    'Zenith': ['Defy', 'Chronomaster', 'Elite', 'Pilot'],
    'TAG Heuer': ['Carrera', 'Monaco', 'Aquaracer', 'Formula 1', 'Autavia'],
    'Seiko': ['Prospex', 'Presage', '5 Sports', 'Astron', 'King Seiko'],
    'Grand Seiko': ['Heritage', 'Elegance', 'Sport', 'Evolution 9'],
    'Tissot': ['PRX', 'Seastar', 'Le Locle', 'Gentleman', 'Supersport'],
    'Longines': ['HydroConquest', 'Master Collection', 'Spirit', 'Heritage', 'DolceVita'],
    'Casio': ['G-Shock', 'Edifice', 'Pro Trek', 'Vintage'],
  };

  final List<String> stanja = ['Sve', 'Novo (Nenošeno)', 'Odlično', 'Vrlo dobro', 'Dobro', 'Za delove'];
  final List<String> materijali = ['Sve', 'Čelik', 'Zlato', 'Titanijum', 'Keramika', 'Platina', 'Karbon'];
  final List<String> mehanizmi = ['Sve', 'Automatik', 'Kvarcni', 'Ručno navijanje', 'Spring Drive'];

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
            Row(
              children: [
                Text(vrednost ?? "Sve", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                const SizedBox(width: 5),
                const Icon(CupertinoIcons.chevron_down, size: 16, color: Colors.grey),
              ],
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
              Text("Detaljni Filteri", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 20),

              _iosFilterDugme("Brend", filterBrend, brendoviIModeli.keys.toList(), (v) => setState(() { filterBrend = v == 'Svi' ? null : v; filterModel = null; })),
              if (filterBrend != null)
                _iosFilterDugme("Model", filterModel, ['Svi', ...brendoviIModeli[filterBrend]!], (v) => setState(() => filterModel = v == 'Svi' ? null : v)),
              
              _iosFilterDugme("Stanje", filterStanje, stanja, (v) => setState(() => filterStanje = v == 'Sve' ? null : v)),
              _iosFilterDugme("Materijal", filterMaterijal, materijali, (v) => setState(() => filterMaterijal = v == 'Sve' ? null : v)),
              _iosFilterDugme("Mehanizam", filterMehanizam, mehanizmi, (v) => setState(() => filterMehanizam = v == 'Sve' ? null : v)),

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
                  if (filterBrend != null && sat['brend'] != filterBrend) return false;
                  if (filterModel != null && sat['model'] != filterModel) return false;
                  if (filterStanje != null && sat['stanje'] != filterStanje) return false;
                  if (filterMaterijal != null && sat['materijal'] != filterMaterijal) return false;
                  if (filterMehanizam != null && sat['mehanizam'] != filterMehanizam) return false;

                  final cena = int.tryParse(sat['cena'].toString()) ?? 0;
                  final minC = int.tryParse(minCenaController.text) ?? 0;
                  final maxC = int.tryParse(maxCenaController.text) ?? 9999999;
                  if (cena < minC || cena > maxC) return false;

                  return true;
                }).toList();

                if (satovi.isEmpty) return const Center(child: Text("Nema rezultata.", style: TextStyle(color: Colors.grey)));

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                  itemCount: satovi.length,
                  itemBuilder: (context, index) {
                    final sat = satovi[index];
                    final slikeStr = sat['slike']?.toString() ?? "";
                    final prvaSlika = slikeStr.isNotEmpty ? slikeStr.split(',')[0] : null;

                    return Container(
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF1C1C1E) : Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 10), blurRadius: 10, offset: const Offset(0, 5))]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              child: Container(
                                color: isDark ? Colors.grey[900] : Colors.grey[100],
                                width: double.infinity,
                                // OVO JE TAJNA ZA UBRZAVANJE - cacheWidth smanjuje potrošnju RAM-a za 80%
                                child: prvaSlika != null ? Image.network(prvaSlika, fit: BoxFit.cover, cacheWidth: 400) : const Icon(Icons.watch, size: 40, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sat['cena_dogovor'] == true ? "Po dogovoru" : "${sat['cena']} €", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isDark ? Colors.white : Colors.black)),
                                const SizedBox(height: 2),
                                Text("${sat['brend']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent)),
                                Text("${sat['model']}", style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          )
                        ],
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
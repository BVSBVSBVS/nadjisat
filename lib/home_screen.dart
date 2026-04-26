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
  
  Set<String> praceniOglasiIds = {};

  String? filterBrend, filterModel, filterStanje, filterMaterijal, filterMehanizam, filterNamena, filterPrecnik, filterMaterijalNarukvice, filterBojaBrojcanika, filterGarancija;
  bool? filterKutija;
  bool? filterPapiri;
  final minCenaController = TextEditingController();
  final maxCenaController = TextEditingController();

  // --- NOVA BAZA BRENDOVA (AZBUČNI RED - 60 komada) ---
  final Map<String, List<String>> brendoviIModeli = {
    'Svi': [],
    'A. Lange & Söhne': ['1815', 'Datograph', 'Grand Lange 1', 'Lange 1', 'Saxonia', 'Zeitwerk', 'Richard Lange'],
    'Audemars Piguet': ['Royal Oak', 'Royal Oak Offshore', 'Code 11.59', 'Jules Audemars', 'Millenary'],
    'Ball Watch': ['Engineer Hydrocarbon', 'Engineer II', 'Engineer III', 'Trainmaster', 'Fireman', 'Roadmaster'],
    'Baume & Mercier': ['Clifton', 'Classima', 'Riviera', 'Hampton', 'Capeland', 'Baumatic'],
    'Blancpain': ['Fifty Fathoms', 'Villeret', 'Bathyscaphe', 'Air Command', 'Léman'],
    'Breguet': ['Classique', 'Marine', 'Type XX', 'Reine de Naples', 'Tradition', 'Heritage'],
    'Breitling': ['Navitimer', 'Chronomat', 'Superocean', 'Avenger', 'Premier', 'Top Time', 'Endurance Pro'],
    'Bulgari': ['Octo Finissimo', 'Octo Roma', 'Serpenti', 'B.zero1', 'Aluminium'],
    'Carl F. Bucherer': ['Manero', 'Patravi', 'Heritage', 'Adamavi', 'ScubaTec'],
    'Cartier': ['Tank', 'Santos', 'Ballon Bleu', 'Pasha', 'Drive de Cartier', 'Panthère'],
    'Casio': ['G-Shock', 'Edifice', 'Pro Trek', 'Baby-G', 'Vintage', 'Oceanus', 'Databank'],
    'Chopard': ['Alpine Eagle', 'L.U.C', 'Mille Miglia', 'Happy Sport', 'Happy Diamonds'],
    'Citizen': ['Promaster', 'Eco-Drive One', 'The Citizen', 'Attesa', 'Series 8', 'Satellite Wave'],
    'Corum': ['Admiral', 'Golden Bridge', 'Bubble', 'Heritage', 'Ti-Bridge'],
    'Czapek': ['Antarctique', 'Quai des Bergues', 'Faubourg de Cracovie', 'Place Vendôme'],
    'Damasko': ['DS30', 'DC56', 'DC57', 'DC66', 'DA36', 'DK10', 'DSub1'],
    'Doxa': ['Sub 200', 'Sub 300', 'Sub 300T', 'Sub 600T', 'Sub 1500T', 'Army'],
    'Eberhard & Co.': ['Chrono 4', 'Tazio Nuvolari', 'Traversetolo', 'Scafograf', '8 Jours'],
    'Eterna': ['KonTiki', 'Heritage', 'Royal Kontiki', 'Eternity', 'Adventic'],
    'F.P. Journe': ['Chronomètre Bleu', 'Chronomètre Souverain', 'Octa Automatique', 'Tourbillon Souverain'],
    'Farer': ['Lander', 'Worldtimer', 'GMT', 'Chronograph', 'Aqua Compressor', 'Field'],
    'Fortis': ['Flieger', 'Marinemaster', 'Cosmonaut', 'Aeromaster', 'Stratoliner'],
    'Franck Muller': ['Vanguard', 'Cintrée Curvex', 'Casablanca', 'Master Square', 'Long Island'],
    'Girard-Perregaux': ['Laureato', 'Bridges', 'Vintage 1945', '1966', 'Free Bridge'],
    'Glashütte Original': ['PanoMaticLunar', 'PanoReserve', 'Senator', 'SeaQ', 'Seventies Chronograph'],
    'Gorilla': ['Fastback', 'Fastback GT', 'Outlaw Drift', 'Thunderbolt'],
    'Grand Seiko': ['Heritage', 'Evolution 9', 'Elegance', 'Sport', 'GMT', 'Diver', 'High-Beat'],
    'H. Moser & Cie.': ['Endeavour', 'Pioneer', 'Heritage', 'Streamliner', 'Venturer'],
    'Hamilton': ['Khaki Field', 'Khaki Aviation', 'Khaki Navy', 'Jazzmaster', 'American Classic', 'Ventura'],
    'Hanhart': ['417 ES', 'Pioneer', 'Primus', 'Preventor', 'MonoControl'],
    'IWC Schaffhausen': ['Portugieser', 'Big Pilot', 'Pilot\'s Watch', 'Ingenieur', 'Portofino', 'Da Vinci'],
    'Jaeger-LeCoultre': ['Reverso', 'Master Control', 'Polaris', 'Atmos', 'Rendez-Vous', 'Geophysic'],
    'Junghans': ['Max Bill', 'Meister', 'Form', 'Spektrum'],
    'Laco': ['Flieger', 'Navy', 'Squad', 'Classic', 'Chronograph'],
    'Longines': ['HydroConquest', 'Spirit', 'Master Collection', 'Heritage', 'Conquest', 'DolceVita', 'Legend Diver'],
    'Louis Moinet': ['Tourbillon', 'Chronograph', 'Moon Race', 'Space Walker'],
    'MB&F': ['Horological Machine', 'Legacy Machine', 'Performance Art'],
    'Maurice Lacroix': ['Aikon', 'Masterpiece', 'Pontos', 'Eliros'],
    'Mido': ['Multifort', 'Ocean Star', 'Baroncelli', 'Commander'],
    'Montblanc': ['Heritage', 'Star Legacy', '1858', 'Summit', 'TimeWalker'],
    'Nomos Glashütte': ['Tangente', 'Club', 'Orion', 'Ludwig', 'Metro', 'Ahoi'],
    'Omega': ['Speedmaster', 'Seamaster', 'Constellation', 'De Ville', 'Aqua Terra'],
    'Oris': ['Aquis', 'Big Crown', 'Divers Sixty-Five', 'Artelier', 'ProPilot'],
    'Panerai': ['Luminor', 'Radiomir', 'Submersible', 'Due'],
    'Parmigiani Fleurier': ['Tonda', 'Kalpa', 'Toric', 'Bugatti'],
    'Patek Philippe': ['Nautilus', 'Calatrava', 'Aquanaut', 'Grand Complications', 'Annual Calendar'],
    'Piaget': ['Altiplano', 'Polo', 'Possession', 'Limelight'],
    'Rado': ['Captain Cook', 'Ceramica', 'DiaStar', 'True Thinline', 'Centrix'],
    'Raymond Weil': ['Freelancer', 'Maestro', 'Toccata', 'Tango'],
    'Richard Mille': ['RM 011', 'RM 027', 'RM 035', 'RM 055', 'RM 067'],
    'Roger Dubuis': ['Excalibur', 'Velvet', 'Knights of the Round Table'],
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Explorer', 'Day-Date', 'Sea-Dweller'],
    'Seiko': ['Prospex', 'Presage', 'Astron', '5 Sports', 'King Seiko', 'Premier'],
    'Sinn': ['U1', '104', '556', 'EZM', '900'],
    'TAG Heuer': ['Carrera', 'Monaco', 'Aquaracer', 'Formula 1', 'Autavia', 'Link'],
    'Tissot': ['PRX', 'Le Locle', 'Seastar', 'Gentleman', 'Heritage', 'Visodate'],
    'Tudor': ['Black Bay', 'Pelagos', 'Royal', 'Ranger', '1926'],
    'Ulysse Nardin': ['Diver', 'Freak', 'Marine', 'Blast'],
    'Vacheron Constantin': ['Overseas', 'Patrimony', 'Historiques', 'Traditionnelle', 'Fiftysix'],
    'Zenith': ['Chronomaster', 'Defy', 'Pilot', 'Elite'],
  };

  final List<String> namene = ['Sve', 'Dres (Dress)', 'Ronilački (Diver)', 'Hronograf (Chronograph)', 'Pilot (Aviator)', 'Sportski/GADA', 'Luksuzni', 'Smartwatch'];
  final List<String> mehanizmi = ['Sve', 'Automatik', 'Manuelni', 'Kvarcni', 'Spring Drive', 'Solar', 'Kinetic'];
  final List<String> precnici = ['Sve', ...List.generate(41, (index) => "${20 + index}mm")];
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
          praceniOglasiIds = response.map((e) => e['oglas_id'].toString()).toSet();
        });
      }
    } catch (e) {
      debugPrint("Greska pri ucitavanju pracenih: $e");
    }
  }

  // --- KORAK 2: FUNKCIJA SA ZABRANOM LAJKOVANJA SVOJIH OGLASA ---
  Future<void> _togglePraceni(String oglasId, String vlasnikOglasaId) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Morate biti prijavljeni da biste pratili oglase.")));
      return;
    }

    // BLOKADA: Ne možeš da lajkuješ svoj sat
    if (user!.id == vlasnikOglasaId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ne možete staviti svoj oglas u omiljene!")));
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

  // --- ISPRAVLJENI FILTERI (DROPDOWN UMESTO IOS TOČKIĆA) ---
  Widget _buildDropdownFilter(String label, String? value, List<String> items, Function(String?) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          suffixIcon: value != null && value != 'Svi' && value != 'Sve' ? IconButton(
            icon: const Icon(CupertinoIcons.clear_circled, color: Colors.grey, size: 20),
            onPressed: () => onChanged(null),
          ) : null,
        ),
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: isDark ? Colors.white : Colors.black)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _otvoriFiltere() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder( // StatefulBuilder osvezava filter prozor na klik
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
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

                  _buildDropdownFilter("Brend", filterBrend, brendoviIModeli.keys.toList(), (v) {
                    setModalState(() { filterBrend = v == 'Svi' ? null : v; filterModel = null; });
                    setState(() { filterBrend = v == 'Svi' ? null : v; filterModel = null; });
                  }),
                  if (filterBrend != null && brendoviIModeli[filterBrend] != null)
                    _buildDropdownFilter("Model", filterModel, ['Svi', ...brendoviIModeli[filterBrend]!], (v) {
                      setModalState(() => filterModel = v == 'Svi' ? null : v);
                      setState(() => filterModel = v == 'Svi' ? null : v);
                    }),
                  
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

                  _buildDropdownFilter("Kategorija / Namena", filterNamena, namene, (v) { setModalState(() => filterNamena = v == 'Sve' ? null : v); setState(() => filterNamena = v == 'Sve' ? null : v); }),
                  _buildDropdownFilter("Stanje", filterStanje, stanja, (v) { setModalState(() => filterStanje = v == 'Sve' ? null : v); setState(() => filterStanje = v == 'Sve' ? null : v); }),
                  _buildDropdownFilter("Garancija", filterGarancija, opcijeGarancije, (v) { setModalState(() => filterGarancija = v == 'Sve' ? null : v); setState(() => filterGarancija = v == 'Sve' ? null : v); }),
                  _buildDropdownFilter("Mehanizam", filterMehanizam, mehanizmi, (v) { setModalState(() => filterMehanizam = v == 'Sve' ? null : v); setState(() => filterMehanizam = v == 'Sve' ? null : v); }),
                  _buildDropdownFilter("Prečnik", filterPrecnik, precnici, (v) { setModalState(() => filterPrecnik = v == 'Sve' ? null : v); setState(() => filterPrecnik = v == 'Sve' ? null : v); }),
                  _buildDropdownFilter("Materijal kućišta", filterMaterijal, materijali, (v) { setModalState(() => filterMaterijal = v == 'Sve' ? null : v); setState(() => filterMaterijal = v == 'Sve' ? null : v); }),
                  _buildDropdownFilter("Materijal narukvice", filterMaterijalNarukvice, materijaliNarukvice, (v) { setModalState(() => filterMaterijalNarukvice = v == 'Sve' ? null : v); setState(() => filterMaterijalNarukvice = v == 'Sve' ? null : v); }),
                  _buildDropdownFilter("Boja brojčanika", filterBojaBrojcanika, bojeBrojcanika, (v) { setModalState(() => filterBojaBrojcanika = v == 'Sve' ? null : v); setState(() => filterBojaBrojcanika = v == 'Sve' ? null : v); }),

                  CheckboxListTile(
                    title: Text("Mora da ima kutiju", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    value: filterKutija ?? false,
                    onChanged: (v) { setModalState(() => filterKutija = v! ? true : null); setState(() => filterKutija = v! ? true : null); },
                    activeColor: Colors.blue,
                  ),
                  CheckboxListTile(
                    title: Text("Mora da ima papire", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    value: filterPapiri ?? false,
                    onChanged: (v) { setModalState(() => filterPapiri = v! ? true : null); setState(() => filterPapiri = v! ? true : null); },
                    activeColor: Colors.blue,
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () { Navigator.pop(context); },
                      child: const Text("Pretraži", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // OVO JE MAGIJA ZA RESPONSIVAN EKRAN
    final screenWidth = MediaQuery.of(context).size.width;
    int brojKolona = 2; // Po defaultu za telefon je 2
    if (screenWidth > 1200) {
      brojKolona = 6; // Širok PC ekran -> 6 kolona
    } else if (screenWidth > 900) {
      brojKolona = 4; // Manji PC ekran ili tablet u položenom položaju -> 4 kolone
    } else if (screenWidth > 600) {
      brojKolona = 3; // Veliki telefoni/mali tableti -> 3 kolone
    }
    
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
                  if (filterNamena != null && sat['namena'] != filterNamena) return false;
                  if (filterPrecnik != null && sat['precnik'] != filterPrecnik) return false;
                  if (filterMaterijalNarukvice != null && sat['materijal_narukvice'] != filterMaterijalNarukvice) return false;
                  if (filterBojaBrojcanika != null && sat['boja_brojcanika'] != filterBojaBrojcanika) return false;
                  if (filterGarancija != null && sat['garancija'] != filterGarancija) return false;
                  if (filterKutija == true && sat['originalna_kutija'] != true) return false;
                  if (filterPapiri == true && sat['originalni_papiri'] != true) return false;

                  final cena = int.tryParse(sat['cena'].toString()) ?? 0;
                  final minC = int.tryParse(minCenaController.text) ?? 0;
                  final maxC = int.tryParse(maxCenaController.text) ?? 9999999;
                  if (cena < minC || cena > maxC) return false;

                  return true;
                }).toList();

                if (satovi.isEmpty) return const Center(child: Text("Nema rezultata.", style: TextStyle(color: Colors.grey)));

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: brojKolona, 
                    crossAxisSpacing: 12, 
                    mainAxisSpacing: 12, 
                    childAspectRatio: 0.72
                  ),
                  itemCount: satovi.length,
                  itemBuilder: (context, index) {
                    final sat = satovi[index];
                    final oglasId = sat['id'].toString(); 
                    final vlasnikId = sat['user_id'].toString(); // IZVLACIMO ID VLASNIKA OGLASA
                    
                    final slikeStr = sat['slike']?.toString() ?? "";
                    
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
                                // ŠALJEMO ID OGLASA I ID VLASNIKA OGLASA U FUNKCIJU
                                onTap: () => _togglePraceni(oglasId, vlasnikId),
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
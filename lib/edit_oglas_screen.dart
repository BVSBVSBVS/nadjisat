import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditOglasScreen extends StatefulWidget {
  final Map<String, dynamic> oglas;
  const EditOglasScreen({super.key, required this.oglas});

  @override
  State<EditOglasScreen> createState() => _EditOglasScreenState();
}

class _EditOglasScreenState extends State<EditOglasScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? izabranBrend, izabranModel, stanje, godina, precnik, lugToLug, materijal, staklo, mehanizam, vodootpornost, kutijaPapiri;
  final cenaController = TextEditingController();
  final opisController = TextEditingController();
  bool cenaPoDogovoru = false;
  
  List<XFile> noveSlike = [];
  String stareSlikeUrl = "";
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  // Ista baza, abecedni red
  final Map<String, List<String>> brendoviIModeli = {
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

  final List<String> godine = List.generate(127, (index) => (2026 - index).toString());
  final List<String> precnici = List.generate(41, (index) => "${20 + index}mm");
  final List<String> lugToLugLista = List.generate(41, (index) => "${30 + index}mm");

  final List<String> stanja = ['1. Novo sa folijama', '2. Kao novo', '3. Odlično', '4. Dobro', '5. Vidljivi tragovi korišćenja'];
  final List<String> materijali = ['Čelik', 'Zlato (18k)', 'Titanijum', 'Platina', 'Keramika', 'Bronza', 'Guma/Plastika'];
  final List<String> stakla = ['Safirno', 'Mineralno', 'Akrilno (Plexi)'];
  final List<String> mehanizmi = ['Automatik', 'Manuelni', 'Kvarcni', 'Spring Drive', 'Solar', 'Kinetic'];
  final List<String> vodootpornosti = ['Nije vodootporan', '30m (3 ATM)', '50m (5 ATM)', '100m (10 ATM)', '200m+ (Diver)'];
  final List<String> opcijeKutija = ['Full Set (Kutija i papiri)', 'Samo kutija', 'Samo papiri', 'Samo sat'];

  @override
  void initState() {
    super.initState();
    final oglas = widget.oglas;
    
    if (brendoviIModeli.containsKey(oglas['brend'])) {
      izabranBrend = oglas['brend'];
      if (brendoviIModeli[izabranBrend]!.contains(oglas['model'])) {
        izabranModel = oglas['model'];
      }
    }
    
    cenaPoDogovoru = oglas['cena_dogovor'] ?? false;
    if (!cenaPoDogovoru && oglas['cena'] != null) cenaController.text = oglas['cena'].toString();
    
    if (stanja.contains(oglas['stanje'])) stanje = oglas['stanje'];
    if (godine.contains(oglas['godina']?.toString())) godina = oglas['godina']?.toString();
    if (precnici.contains(oglas['precnik'])) precnik = oglas['precnik'];
    if (lugToLugLista.contains(oglas['lug_to_lug'])) lugToLug = oglas['lug_to_lug'];
    if (materijali.contains(oglas['materijal'])) materijal = oglas['materijal'];
    if (stakla.contains(oglas['staklo'])) staklo = oglas['staklo'];
    if (mehanizmi.contains(oglas['mehanizam'])) mehanizam = oglas['mehanizam'];
    if (vodootpornosti.contains(oglas['vodootpornost'])) vodootpornost = oglas['vodootpornost'];
    if (opcijeKutija.contains(oglas['kutija_papiri'])) kutijaPapiri = oglas['kutija_papiri'];
    
    opisController.text = oglas['opis'] ?? '';
    stareSlikeUrl = oglas['slike'] ?? '';
  }

  Future<void> _izaberiSlike() async {
    final List<XFile> slike = await _picker.pickMultiImage();
    if (slike.isNotEmpty) {
      setState(() {
        noveSlike = slike;
        if (noveSlike.length > 16) {
          noveSlike = noveSlike.sublist(0, 16);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Max 16 slika.")));
        }
      });
    }
  }

  Future<void> _azurirajOglas() async {
    if (izabranBrend == null || izabranModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Popuni obavezna polja!")));
      return;
    }

    setState(() => isUploading = true);

    try {
      String konacneSlike = stareSlikeUrl;

      if (noveSlike.isNotEmpty) {
        List<String> slikeUrls = [];
        for (var slika in noveSlike) {
          final bytes = await slika.readAsBytes();
          final imeFajla = '${DateTime.now().millisecondsSinceEpoch}_${slika.name}';
          try {
            await Supabase.instance.client.storage.from('slike_oglasi').uploadBinary(imeFajla, bytes);
            slikeUrls.add(Supabase.instance.client.storage.from('slike_oglasi').getPublicUrl(imeFajla));
          } catch (_) {
            await Supabase.instance.client.storage.from('slike-oglasi').uploadBinary(imeFajla, bytes);
            slikeUrls.add(Supabase.instance.client.storage.from('slike-oglasi').getPublicUrl(imeFajla));
          }
        }
        konacneSlike = slikeUrls.join(',');
      }

      await Supabase.instance.client.from('satovi').update({
        'naslov': '$izabranBrend $izabranModel',
        'brend': izabranBrend,
        'model': izabranModel,
        'cena': cenaPoDogovoru ? null : (int.tryParse(cenaController.text.trim()) ?? 0), 
        'cena_dogovor': cenaPoDogovoru,
        'godina': godina,
        'precnik': precnik,
        'lug_to_lug': lugToLug,
        'stanje': stanje,
        'materijal': materijal,
        'staklo': staklo,
        'mehanizam': mehanizam,
        'vodootpornost': vodootpornost,
        'kutija_papiri': kutijaPapiri,
        'opis': opisController.text.trim(),
        'slike': konacneSlike,
      }).eq('id', widget.oglas['id']); 

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oglas uspešno izmenjen!")));
      Navigator.pop(context); 
      
    } catch (e) {
      if (!mounted) return;
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Greška: $e")));
    }
  }

  // --- OVO JE ISTI DROP MENU SA "X" DUGMETOM ZA PONIŠTAVANJE ---
  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          suffixIcon: value != null ? IconButton(
            icon: const Icon(CupertinoIcons.clear_circled, color: Colors.grey, size: 20),
            onPressed: () => onChanged(null), // Na klik briše vrednost (vraća null)
          ) : null,
        ),
        dropdownColor: isDark ? Colors.grey[800] : Colors.white,
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: isDark ? Colors.white : Colors.black)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: const Text("Izmeni oglas", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: isUploading ? const Center(child: CupertinoActivityIndicator(radius: 20)) : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _izaberiSlike,
              child: Container(
                height: 120,
                decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.camera, size: 40, color: Colors.blue),
                    SizedBox(height: 8),
                    Text("Zameni slike (ili ostavi prazno da zadržiš stare)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 12), textAlign: TextAlign.center,)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildDropdown("Brend", izabranBrend, brendoviIModeli.keys.toList(), (v) => setState(() { 
                    izabranBrend = v; 
                    izabranModel = null; // Briše model
                  })),
                  if (izabranBrend != null && brendoviIModeli[izabranBrend] != null)
                    _buildDropdown("Model", izabranModel, brendoviIModeli[izabranBrend]!, (v) => setState(() => izabranModel = v)),
                  
                  Row(
                    children: [
                      Text("Kontakt / Po dogovoru", style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                      const Spacer(),
                      CupertinoSwitch(
                        value: cenaPoDogovoru,
                        activeTrackColor: Colors.blue, 
                        onChanged: (v) => setState(() { cenaPoDogovoru = v; if(v) cenaController.clear(); }),
                      ),
                    ],
                  ),
                  if (!cenaPoDogovoru)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: CupertinoTextField(
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        controller: cenaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false), 
                        placeholder: "Cena (€)",
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildDropdown("Stanje", stanje, stanja, (v) => setState(() => stanje = v)),
                  _buildDropdown("Godina", godina, godine, (v) => setState(() => godina = v)),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown("Prečnik", precnik, precnici, (v) => setState(() => precnik = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _buildDropdown("Lug-to-Lug", lugToLug, lugToLugLista, (v) => setState(() => lugToLug = v))),
                    ],
                  ),
                  _buildDropdown("Materijal", materijal, materijali, (v) => setState(() => materijal = v)),
                  _buildDropdown("Staklo", staklo, stakla, (v) => setState(() => staklo = v)),
                  _buildDropdown("Mehanizam", mehanizam, mehanizmi, (v) => setState(() => mehanizam = v)),
                  _buildDropdown("Vodootpornost", vodootpornost, vodootpornosti, (v) => setState(() => vodootpornost = v)),
                  _buildDropdown("Kutija i Papiri", kutijaPapiri, opcijeKutija, (v) => setState(() => kutijaPapiri = v)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            CupertinoTextField(
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              controller: opisController,
              maxLines: 4,
              placeholder: "Opis",
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300)),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CupertinoButton(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
                onPressed: _azurirajOglas,
                child: const Text("Sačuvaj izmene", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
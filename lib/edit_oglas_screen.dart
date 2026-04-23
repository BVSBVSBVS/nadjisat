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
    'Glashütte Original': ['PanomaticLunar', 'Senator', 'SeaQ', 'Sixties', 'Seventies'],
    'Grand Seiko': ['Heritage', 'Elegance', 'Sport', 'Evolution 9', 'Masterpiece'],
    'Hamilton': ['Khaki Field', 'Khaki Aviation', 'Khaki Navy', 'Ventura', 'Jazzmaster', 'American Classic'],
    'Hanhart': ['417 ES', 'Pioneer', 'Primus', 'Stopwatches'],
    'Hublot': ['Big Bang', 'Classic Fusion', 'Spirit of Big Bang', 'MP Collection', 'King Power'],
    'IWC Schaffhausen': ['Portugieser', 'Big Pilot', 'Pilot\'s Watch', 'Ingenieur', 'Portofino', 'Da Vinci'],
    'Jaeger-LeCoultre': ['Reverso', 'Master Control', 'Polaris', 'Atmos', 'Rendez-Vous', 'Geophysic'],
    'Junghans': ['Max Bill', 'Meister', 'Form', 'Spektrum'],
    'Laco': ['Flieger', 'Navy', 'Squad', 'Classic', 'Chronograph'],
    'Longines': ['HydroConquest', 'Spirit', 'Master Collection', 'Heritage', 'Conquest', 'DolceVita', 'Legend Diver'],
    'Louis Moinet': ['Tourbillon', 'Chronograph', 'Moon Race', 'Space Walker'],
    'Maurice Lacroix': ['Aikon', 'Masterpiece', 'Pontos', 'Eliros'],
    'MB&F': ['Horological Machine', 'Legacy Machine', 'Performance Art'],
    'Montblanc': ['Heritage', 'Star Legacy', '1858', 'Summit', 'TimeWalker'],
    'Mido': ['Multifort', 'Ocean Star', 'Baroncelli', 'Commander'],
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
    'Rolex': ['Submariner', 'Daytona', 'Datejust', 'GMT-Master II', 'Explorer', 'Day-Date', 'Sea-Dweller'],
    'Roger Dubuis': ['Excalibur', 'Velvet', 'Knights of the Round Table'],
    'Seiko': ['Prospex', 'Presage', 'Astron', '5 Sports', 'King Seiko', 'Premier'],
    'Sinn': ['U1', '104', '556', '903', '356', 'EZM'],
    'TAG Heuer': ['Carrera', 'Monaco', 'Aquaracer', 'Formula 1', 'Autavia', 'Connected'],
    'Tissot': ['PRX', 'Seastar', 'Le Locle', 'Gentleman', 'T-Touch', 'Chemin des Tourelles'],
    'Tudor': ['Black Bay', 'Pelagos', 'Ranger', 'Royal', '1926'],
    'Ulysse Nardin': ['Freak', 'Marine', 'Diver', 'Blast', 'Executive'],
    'Vacheron Constantin': ['Overseas', 'Patrimony', 'Traditionnelle', 'Fiftysix', 'Historiques'],
    'Zenith': ['Chronomaster', 'Defy', 'Elite', 'Pilot'],
    'Zodiac': ['Sea Wolf', 'Super Sea Wolf', 'Grandrally', 'Olympos'],
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
                scrollController: FixedExtentScrollController(initialItem: 0),
                onSelectedItemChanged: (index) => onOdabrano(opcije[index]),
                children: opcije.map((o) => Center(child: Text(o, style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iosPoljeZaBiranje(String label, String? trenutnaVrednost, List<String> opcije, Function(String) onOdabrano) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: opcije.isEmpty ? null : () => _prikaziIOSPicker(label, opcije, onOdabrano),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade300)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(trenutnaVrednost ?? label, style: TextStyle(fontSize: 16, color: trenutnaVrednost == null ? Colors.grey : (isDark ? Colors.white : Colors.black))),
            const Icon(CupertinoIcons.chevron_down, color: Colors.grey, size: 18),
          ],
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
                  _iosPoljeZaBiranje("Brend", izabranBrend, brendoviIModeli.keys.toList(), (v) => setState(() { izabranBrend = v; izabranModel = null; })),
                  _iosPoljeZaBiranje("Model", izabranModel, izabranBrend != null ? brendoviIModeli[izabranBrend]! : [], (v) => setState(() => izabranModel = v)),
                  
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
                  _iosPoljeZaBiranje("Stanje", stanje, stanja, (v) => setState(() => stanje = v)),
                  _iosPoljeZaBiranje("Godina", godina, godine, (v) => setState(() => godina = v)),
                  Row(
                    children: [
                      Expanded(child: _iosPoljeZaBiranje("Prečnik", precnik, precnici, (v) => setState(() => precnik = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _iosPoljeZaBiranje("Lug-to-Lug", lugToLug, lugToLugLista, (v) => setState(() => lugToLug = v))),
                    ],
                  ),
                  _iosPoljeZaBiranje("Materijal", materijal, materijali, (v) => setState(() => materijal = v)),
                  _iosPoljeZaBiranje("Staklo", staklo, stakla, (v) => setState(() => staklo = v)),
                  _iosPoljeZaBiranje("Mehanizam", mehanizam, mehanizmi, (v) => setState(() => mehanizam = v)),
                  _iosPoljeZaBiranje("Vodootpornost", vodootpornost, vodootpornosti, (v) => setState(() => vodootpornost = v)),
                  _iosPoljeZaBiranje("Kutija i Papiri", kutijaPapiri, opcijeKutija, (v) => setState(() => kutijaPapiri = v)),
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